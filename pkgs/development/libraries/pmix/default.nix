{ stdenv, fetchurl, libevent }:

stdenv.mkDerivation rec {
  name = "pmix-2.1.2";

  src = fetchurl {
    url = "https://github.com/pmix/pmix/releases/download/v2.1.2/pmix-2.1.2.tar.bz2";
    sha256 = "94bb9c801c51a6caa1b8cef2b85ecf67703a5dfa4d79262e6668c37c744bb643";
  };

  buildInputs = [ libevent ];

  configureFlags = [ "--with-libevent=${libevent.dev}" ];

  meta = with stdenv.lib; {
    homepage = https://pmix.org/;
    platforms = platforms.unix;
  };
}
