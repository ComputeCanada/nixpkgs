{ stdenv, fetchurl, pkgconfig, graphviz, numactl, binutils, libiberty,
  libibverbs_mlnx, librdmacm_mlnx, libibcm_mlnx, zlib, knem, doxygen, perl, texlive }:

stdenv.mkDerivation rec {
  version = "1.4.0";
  name = "ucx-${version}";

  src = fetchurl {
    url = "https://github.com/openucx/ucx/releases/download/v${version}/${name}.tar.gz";
    sha256 = "99891a98476bcadc6ac4ef9c9f083bc6ffb188a96b3c3bc89c8bbca64de2c76e";
  };

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ numactl graphviz binutils libiberty libibverbs_mlnx librdmacm_mlnx libibcm_mlnx zlib knem
                  doxygen perl texlive.combined.scheme-basic ];

  configureScript = "./contrib/configure-release";
  configureFlags = [ "--with-verbs=${libibverbs_mlnx}" "--with-rdmacm=${librdmacm_mlnx}" "--with-knem=${knem}" ];

  hardeningDisable = [ "bindnow" ];

  meta = with stdenv.lib; {
    homepage = https://www.openucx.org/;
    license = licenses.bsd3;
    platforms = platforms.unix;
  };
}
