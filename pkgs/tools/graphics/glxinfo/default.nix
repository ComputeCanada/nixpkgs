{ stdenv, fetchurl, xlibsWrapper, libGL }:

let version = "8.3.0"; in

stdenv.mkDerivation {
  name = "glxinfo-${version}";

  src = fetchurl {
    url = "ftp://ftp.freedesktop.org/pub/mesa/demos/${version}/mesa-demos-${version}.tar.bz2";
    sha256 = "1vqb7s5m3fcg2csbiz45mha1pys2xx6rhw94fcyvapqdpm5iawy1";
  };

  buildInputs = [ xlibsWrapper libGL ];

  configurePhase = "true";

  buildPhase = "
    export NIX_LDFLAGS=\"$NIX_LDFLAGS -L${libGL}/lib\"
    $CC src/xdemos/{glxinfo.c,glinfo_common.c} -o glxinfo -lGL -lX11
    $CC src/xdemos/glxgears.c -o glxgears -lGL -lX11 -lm
    $CC src/egl/opengles2/es2_info.c -o es2_info -lEGL -lGLESv2 -lX11
    $CC src/egl/opengles2/es2gears.c src/egl/eglut/{eglut.c,eglut_x11.c} -o es2gears -Isrc/egl/eglut -lEGL -lGLESv2 -lX11 -lm
  ";

  installPhase = "
    install -Dm 555 -t $out/bin glx{info,gears} es2{_info,gears}
  ";

  meta = {
    platforms = stdenv.lib.platforms.linux;
  };
}
