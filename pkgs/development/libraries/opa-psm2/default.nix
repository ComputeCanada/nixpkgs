{ stdenv, fetchurl, libuuid, numactl }:

stdenv.mkDerivation rec {
  name = "opa-psm2-10.3.8";

  src = fetchurl {
    url = "https://github.com/01org/opa-psm2/archive/IFS_RELEASE_10_6_0_0_134.tar.gz";
    sha256 = "0h4g5bzcnjhjmid8rn889a6cfqq0f1fn8kkmhizdhngl8czwjnvh";
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
