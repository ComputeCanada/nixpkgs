{ stdenv, fetchurl, autoconf, automake, libtool, libibverbs, valgrind }:

stdenv.mkDerivation rec {
  name = "opa-libhfi1verbs-10.1.2";

  src = fetchurl {
    url = "https://github.com/01org/opa-libhfi1verbs/archive/10_1_2.tar.gz";
    sha256 = "895c7485c00331bf5d573678affa6a7436e7aae81d6f00277695b6007caa699c";
  };

  buildInputs = [ autoconf automake libtool libibverbs valgrind ];

  preConfigure = "rm makefile && ./autogen.sh";

  meta = with stdenv.lib; {
    homepage = https://www.openfabrics.org/;
    license = licenses.bsd2;
    platforms = platforms.unix;
  };
}
