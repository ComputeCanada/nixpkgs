{ stdenv, fetchurl, cmake, glproto, libGLU, libGL, libX11, libXv, libXtst, libjpeg_turbo, fltk, xorg }:

stdenv.mkDerivation rec {
  name = "virtualgl-lib-${version}";
  version = "2.6.5";

  src = fetchurl {
    url = "mirror://sourceforge/virtualgl/VirtualGL-${version}.tar.gz";
    sha256 = "1giin3jmcs6y616bb44bpz30frsmj9f8pz2vg7jvb9vcfc9456rr";
  };

  patches = [ ./find-host-vgl-libraries.patch ];

  cmakeFlags = [ "-DVGL_SYSTEMFLTK=1" "-DTJPEG_LIBRARY=${libjpeg_turbo.out}/lib/libturbojpeg.so"
                 "-DOPENGL_gl_LIBRARY=${libGL}/lib/libGL.so"
                 "-DVGL_FAKEOPENCL=OFF" ];

  makeFlags = [ "PREFIX=$(out)" ];

  nativeBuildInputs = [ cmake ];

  buildInputs = [ libjpeg_turbo glproto libGLU libGL fltk libX11 libXv libXtst xorg.xcbutilkeysyms ];

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    homepage = "http://www.virtualgl.org/";
    description = "X11 GL rendering in a remote computer with full 3D hw acceleration";
    license = licenses.free; # many parts under different free licenses
    platforms = platforms.linux;
    maintainers = with maintainers; [ abbradar ];
  };
}
