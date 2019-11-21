{ stdenv, fetchurl, autoconf, automake, git, libtool, gettext, pkgconfig, graphviz, numactl, binutils, libiberty,
  rdma-core, zlib, knem, doxygen, perl, texlive }:

stdenv.mkDerivation rec {
  version = "1.5.2";
  name = "ucx-${version}";

  src = fetchurl {
    url = "https://github.com/openucx/ucx/releases/download/v${version}/${name}.tar.gz";
    sha256 = "1b9zj63807y67rkjn3kr0fb20wcqrhf0g3cvlrmyhq4q0r9khcqs";
  };

  nativeBuildInputs = [ autoconf automake git libtool gettext pkgconfig ];
  buildInputs = [ numactl graphviz binutils libiberty rdma-core zlib knem
                  doxygen perl texlive.combined.scheme-basic ];

  #preConfigure = "./autogen.sh";
  configureScript = "./contrib/configure-release";
  configureFlags = [ "--with-verbs=${rdma-core}" "--with-rdmacm=${rdma-core}" "--with-knem=${knem}"
                     "--disable-optimizations" "--enable-mt" "--without-cm"];

  hardeningDisable = [ "bindnow" ];

  meta = with stdenv.lib; {
    homepage = https://www.openucx.org/;
    license = licenses.bsd3;
    platforms = platforms.unix;
  };
}
