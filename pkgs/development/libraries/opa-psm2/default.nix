{ stdenv, fetchurl, libuuid, numactl }:

stdenv.mkDerivation rec {
  name = "opa-psm2-11.2.23";

  src = fetchurl {
    url = "https://github.com/01org/opa-psm2/archive/IFS_RELEASE_10_8_0_0_204.tar.gz";
    sha256 = "19820zjmv99qr9xy7k57zjyk2x353xx76yiq04xa907p9qfsn0dd";
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
