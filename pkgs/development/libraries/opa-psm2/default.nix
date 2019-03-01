{ stdenv, fetchurl, libuuid, numactl }:

stdenv.mkDerivation rec {
  name = "opa-psm2-11.2.78";

  src = fetchurl {
    url = "https://github.com/01org/opa-psm2/archive/IFS_RELEASE_10_9_0_1_5.tar.gz";
    sha256 = "1x34da00a00y4xvvcqc55fv69zx2ki897l4pchrvw2a7gzfcxrpi";
  };

  configurePhase = "sed -i 's|/usr|/|' Makefile";

  patches = [ ./opa-psm2-hfi-user.patch ];

  hardeningDisable = [ "format" ];

  buildInputs = [ libuuid numactl ];
  buildPhase = "make arch=x86_64 USE_PSM_UUID=1 WERROR=";

  installPhase = "make install arch=x86_64 DESTDIR=$out";

  meta = with stdenv.lib; {
    homepage = https://www.openfabrics.org/;
    license = licenses.bsd2;
    platforms = platforms.unix;
  };
}
