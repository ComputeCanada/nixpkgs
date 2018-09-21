{ stdenv, fetchurl, pkgconfig, graphviz, numactl, binutils, libiberty, libibverbs, zlib, knem, doxygen, perl, texlive }:

stdenv.mkDerivation rec {
  version = "1.3.1";
  name = "ucx-${version}";

  src = fetchurl {
    url = "https://github.com/openucx/ucx/releases/download/v${version}/${name}.tar.gz";
    sha256 = "14l9gbg7jhcvigjhmwkd3rnavljw23palfhyvgcm0bqdhgnchn70";
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
