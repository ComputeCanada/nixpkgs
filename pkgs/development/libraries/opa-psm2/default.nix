{ stdenv, fetchurl, libuuid }:

stdenv.mkDerivation rec {
  name = "opa-psm2-10.3.1";

  src = fetchurl {
    url = "https://github.com/01org/opa-psm2/archive/IFS_RELEASE_10_3_1_0_22.tar.gz";
    sha256 = "7fde8c0204c9690404f22d59f45b12b820ce36d67a612fb7045f68f2670fefb3";
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
