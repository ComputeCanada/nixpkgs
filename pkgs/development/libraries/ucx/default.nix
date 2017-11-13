{ stdenv, fetchurl, pkgconfig, graphviz, numactl, binutils, libiberty, libibverbs, zlib, knem, doxygen, perl, texlive }:

stdenv.mkDerivation rec {
  version = "1.2.1";
  name = "ucx-${version}";

  src = fetchurl {
    url = "https://github.com/openucx/ucx/releases/download/v${version}/${name}.tar.gz";
    sha256 = "fc63760601c03ff60a2531ec3c6637e98f5b743576eb410f245839c84a0ad617";
  };

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ numactl graphviz binutils libiberty libibverbs zlib knem doxygen perl texlive.combined.scheme-basic ];

  configureFlags = [ "--with-verbs=${libibverbs}" "--with-knem=${knem}" ];

  meta = with stdenv.lib; {
    homepage = https://www.openucx.org/;
    license = licenses.bsd3;
    platforms = platforms.unix;
  };
}
