{ stdenv, fetchurl, autoconf, automake, git, libtool, gettext, pkgconfig, graphviz, numactl, binutils, libiberty,
  rdma-core, zlib, knem, doxygen, perl, texlive }:

stdenv.mkDerivation rec {
  version = "1.5.0";
  name = "ucx-${version}";

  src = fetchurl {
    url = "https://github.com/openucx/ucx/releases/download/v${version}/${name}.tar.gz";
    sha256 = "0n3lgm5rxj4drp7hs4l3dz2mhvi00xf41fy8n6wypbs0azxf9xl4";
  };
  patches = [./0001-UCT-IB-MLX5-Fasten-DC-support-check.patch];

  nativeBuildInputs = [ autoconf automake git libtool gettext pkgconfig ];
  buildInputs = [ numactl graphviz binutils libiberty rdma-core zlib knem
                  doxygen perl texlive.combined.scheme-basic ];

  #preConfigure = "./autogen.sh";
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
