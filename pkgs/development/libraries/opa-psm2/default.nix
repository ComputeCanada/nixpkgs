{ stdenv, fetchurl, libuuid }:

stdenv.mkDerivation rec {
  name = "opa-psm2-10.2.42";

  src = fetchurl {
    url = "https://github.com/01org/opa-psm2/archive/PSM2_10.2-42.tar.gz";
    sha256 = "1hkvir82m5257q6dv85825h3v2azy8bdl7aarn9lrkawk8c8lg4w";
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
