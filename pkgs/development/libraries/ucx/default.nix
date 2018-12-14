{ stdenv, fetchurl, autoconf, automake, git, libtool, gettext, pkgconfig, graphviz, numactl, binutils, libiberty,
  rdma-core, zlib, knem, doxygen, perl, texlive }:

stdenv.mkDerivation rec {
  version = "1.5.0-hpcx-v2.3";
  name = "ucx-${version}";

  src = fetchurl {
    #url = "https://github.com/openucx/ucx/releases/download/v${version}/${name}.tar.gz";
    url = "https://github.com/openucx/ucx/archive/hpcx-v2.3.tar.gz";
    sha256 = "44bdd30d54cbe30d98775f9bde490355f78048460fef0259feeb1a405fc1a248";
  };

  nativeBuildInputs = [ autoconf automake git libtool gettext pkgconfig ];
  buildInputs = [ numactl graphviz binutils libiberty rdma-core zlib knem
                  doxygen perl texlive.combined.scheme-basic ];

  preConfigure = "./autogen.sh";
  configureScript = "./contrib/configure-release";
  configureFlags = [ "--with-verbs=${rdma-core}" "--with-rdmacm=${rdma-core}" "--with-knem=${knem}"
                     "--disable-optimizations" "--enable-mt"];

  hardeningDisable = [ "bindnow" ];

  meta = with stdenv.lib; {
    homepage = https://www.openucx.org/;
    license = licenses.bsd3;
    platforms = platforms.unix;
  };
}
