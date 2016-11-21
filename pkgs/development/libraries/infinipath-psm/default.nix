{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  name = "infinipath-psm-3.3";

  src = fetchurl {
    url = "https://www.openfabrics.org/downloads/infinipath-psm/${name}-19_g67c0807_open.tar.gz";
    sha256 = "6d8ac295463ef895adb2343ccb06057a209ae2b12a319b5f689cf47e140a4d5a";
  };

  configurePhase = "sed -i 's|/usr|/|' Makefile";

  buildPhase = "make arch=x86_64 USE_PSM_UUID=1 WERROR=";

  installPhase = "make install arch=x86_64 DESTDIR=$out";

  meta = with stdenv.lib; {
    homepage = https://www.openfabrics.org/;
    license = licenses.bsd2;
    platforms = platforms.unix;
  };
}
