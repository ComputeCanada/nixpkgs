{ stdenv, fetchurl, libscif, librdmacm, libibverbs }:

stdenv.mkDerivation rec {
  name = "dapl-2.1.10";

  src = fetchurl {
    url = "https://www.openfabrics.org/downloads/dapl/${name}.tar.gz";
    sha256 = "8eb6df3b47fcaad8ea6d35453ffc884b1ef2148f7a0984a3556795bab650fa9b";
  };

  buildInputs = [ libscif librdmacm libibverbs ];

  meta = with stdenv.lib; {
    homepage = https://www.openfabrics.org/;
    platforms = with platforms; linux ++ freebsd;
    license = [ licenses.bsd3 licenses.gpl2 licenses.cpl ];
  };
}
