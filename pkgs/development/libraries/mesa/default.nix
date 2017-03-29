{ stdenv, fetchurl, fetchpatch
, pkgconfig, intltool, autoreconfHook, substituteAll
, file, expat, libdrm, xorg, wayland, systemd
, llvmPackages, libffi, libomxil-bellagio
, libelf, python
, grsecEnabled ? false
, enableTextureFloats ? false # Texture floats are patented, see docs/patents.txt
}:


/** Packaging design:
  - The basic mesa ($out) contains headers and libraries (GLU is in mesa_glu now).
    This or the mesa attribute (which also contains GLU) are small (~ 2 MB, mostly headers)
    and are designed to be the buildInput of other packages.
  - DRI drivers are compiled into $drivers output, which is much bigger and
    depends on LLVM. These should be searched at runtime in
    "/run/opengl-driver{,-32}/lib/*" and so are kind-of impure (given by NixOS).
    (I suppose on non-NixOS one would create the appropriate symlinks from there.)
  - libOSMesa is in $osmesa (~4 MB)
*/

with stdenv.lib;

if ! lists.elem stdenv.system platforms.mesaPlatforms then
  throw "unsupported platform for Mesa"
else

let
  version = "17.0.2";
  branch  = head (splitString "." version);
  driverLink = "/run/opengl-driver" + optionalString stdenv.isi686 "-32";
in

stdenv.mkDerivation {
  name = "mesa-noglu-${version}";

  src =  fetchurl {
    urls = [
      "ftp://ftp.freedesktop.org/pub/mesa/mesa-${version}.tar.xz"
      "ftp://ftp.freedesktop.org/pub/mesa/${version}/mesa-${version}.tar.xz"
      "ftp://ftp.freedesktop.org/pub/mesa/older-versions/${branch}.x/${version}/mesa-${version}.tar.xz"
      "https://launchpad.net/mesa/trunk/${version}/+download/mesa-${version}.tar.xz"
    ];
    sha256 = "f8f191f909e01e65de38d5bdea5fb057f21649a3aed20948be02348e77a689d4";
  };

  prePatch = "patchShebangs .";

  # TODO:
  #  revive ./dricore-gallium.patch when it gets ported (from Ubuntu), as it saved
  #  ~35 MB in $drivers; watch https://launchpad.net/ubuntu/+source/mesa/+changelog
  patches = [
    ./glx_ro_text_segm.patch # fix for grsecurity/PaX
    ./symlink-drivers.patch
  ];

  outputs = [ "out" "dev" "drivers" "osmesa" ];

  # TODO: Figure out how to enable opencl without having a runtime dependency on clang
  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    (optionalString (stdenv.system != "armv7l-linux")
      "--with-gallium-drivers=svga,i915,ilo,r300,r600,nouveau,swrast,swr")

    (enableFeature enableTextureFloats "texture-float")
    (enableFeature grsecEnabled "glx-rts")
    "--disable-dri"
    "--disable-driglx-direct"
    "--enable-gles1"
    "--enable-gles2"
    "--enable-glx"
    "--enable-glx-tls"
    "--disable-osmesa"
    "--enable-gallium-osmesa" # used by wine
    "--enable-gallium-llvm"
    "--disable-egl"
    "--enable-xa" # used in vmware driver
    "--disable-gbm"
    "--enable-xvmc"
    "--enable-shared-glapi"
    "--enable-sysfs"
    "--enable-llvm-shared-libs"
    "--enable-omx"
    "--disable-va"
    "--disable-opencl"
  ];

  nativeBuildInputs = [ pkgconfig file ];

  propagatedBuildInputs = with xorg;
    [ libXdamage libXxf86vm ]
    ++ optional stdenv.isLinux libdrm;

  buildInputs = with xorg; [
    autoreconfHook intltool expat llvmPackages.llvm
    glproto dri2proto dri3proto presentproto
    libX11 libXext libxcb libXt libXfixes libxshmfence
    libffi wayland libelf libXvMC
    libomxil-bellagio libpthreadstubs
    (python.withPackages (ps: [ ps.Mako ]))
  ] ++ optional stdenv.isLinux systemd;


  enableParallelBuilding = true;
  doCheck = false;

  installFlags = [
    "sysconfdir=\${out}/etc"
    "localstatedir=\${TMPDIR}"
  ];

  # TODO: probably not all .la files are completely fixed, but it shouldn't matter;
  postInstall = ''
    mkdir -p $drivers/lib

    # move gallium-related stuff to $drivers, so $out doesn't depend on LLVM
    mv -t "$drivers/lib/"    \
      $out/lib/libXvMC*      \
      $out/lib/bellagio      \
      $out/lib/libxatracker* \

    # move libOSMesa to $osmesa, as it's relatively big
    mkdir -p {$osmesa,$drivers}/lib/
    mv -t $osmesa/lib/ $out/lib/libOSMesa*

    # now fix references in .la files
    sed "/^libdir=/s,$out,$osmesa," -i $osmesa/lib/libOSMesa*.la
  '';

  # TODO:
  #  @vcunat isn't sure if drirc will be found when in $out/etc/;
  #  check $out doesn't depend on llvm: builder failures are ignored
  #  for some reason grep -qv '${llvmPackages.llvm}' -R "$out";
  postFixup = ''
    # add RPATH so the drivers can find the moved libgallium and libdricore9
    # moved here to avoid problems with stripping patchelfed files
    for lib in $drivers/lib/*.so* $drivers/lib/*/*.so*; do
      if [[ ! -L "$lib" ]]; then
        patchelf --set-rpath "$(patchelf --print-rpath $lib):$drivers/lib" "$lib"
      fi
    done
  '';

  passthru = { inherit libdrm version driverLink; };

  meta = with stdenv.lib; {
    description = "An open source implementation of OpenGL";
    homepage = http://www.mesa3d.org/;
    license = licenses.mit; # X11 variant, in most files
    platforms = platforms.mesaPlatforms;
    maintainers = with maintainers; [ eduarrrd vcunat ];
  };
}
