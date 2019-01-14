{ stdenv, requireFile, libibverbs_mlnx }:

stdenv.mkDerivation rec {
  name = "libibcm-41mlnx1";

  src = requireFile {
    name = "${name}.tar.gz";
    url = "file:///localhost";
    sha256 = "3bad0c99eb42471abc23a2a9ff19bb5d9d3c893be58623a0a304ac6ff1b452ae";
  };

  buildInputs = [ libibverbs_mlnx ];

  meta = with stdenv.lib; {
    homepage = https://www.openfabrics.org/;
    platforms = with platforms; linux ++ freebsd;
    license = licenses.bsd2;
  };
}
