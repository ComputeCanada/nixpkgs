{ stdenv, fetchurl, libuuid }:

stdenv.mkDerivation rec {
  name = "opa-psm2-10.2.42";

  src = fetchurl {
    url = " https://github.com/01org/opa-psm2/archive/PSM2_10_2_42.tar.gz";
    sha256 = "039445a973d3f222a70122d6099aa5ae7a912d92ddcb123110da5dd85f39a5d9";
  };

  configurePhase = "sed -i 's|/usr|/|' Makefile";

  patches = [ ./opa-psm2-hfi-user.patch ];

  hardeningDisable = [ "format" ];

  buildInputs = [ libuuid ];
  buildPhase = "make arch=x86_64 USE_PSM_UUID=1 WERROR=";

  installPhase = "make install arch=x86_64 DESTDIR=$out";

  meta = with stdenv.lib; {
    homepage = https://www.openfabrics.org/;
    license = licenses.bsd2;
    platforms = platforms.unix;
  };
}
