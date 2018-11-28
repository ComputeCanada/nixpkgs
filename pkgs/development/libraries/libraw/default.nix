{ stdenv, fetchurl, lcms2, jasper, pkgconfig }:

stdenv.mkDerivation rec {
  name = "libraw-${version}";
  version = "0.17.2";

  src = fetchurl {
    url = "https://www.libraw.org/data/LibRaw-${version}.tar.gz";
    sha256 = "0p6imxpsfn82i0i9w27fnzq6q6gwzvb9f7sygqqakv36fqnc9c4j";
  };

  outputs = [ "out" "lib" "dev" "doc" ];

  buildInputs = [ jasper ];

  propagatedBuildInputs = [ lcms2 ];

  nativeBuildInputs = [ pkgconfig ];

  meta = {
    description = "Library for reading RAW files obtained from digital photo cameras (CRW/CR2, NEF, RAF, DNG, and others)";
    homepage = https://www.libraw.org/;
    license = stdenv.lib.licenses.gpl2Plus;
    platforms = stdenv.lib.platforms.linux;
  };
}

