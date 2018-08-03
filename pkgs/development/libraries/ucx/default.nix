{ stdenv, fetchurl, pkgconfig, graphviz, numactl, binutils, libiberty, libibverbs, zlib, knem, doxygen, perl, texlive }:

stdenv.mkDerivation rec {
  version = "1.3.0";
  name = "ucx-${version}";

  src = fetchurl {
    url = "https://github.com/openucx/ucx/releases/download/v${version}/${name}.tar.gz";
    sha256 = "71e69e6d78a4950cc5a1edcbe59bf7a8f8e38d59c9f823109853927c4d442952";
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
