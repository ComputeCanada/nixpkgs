{ stdenv, requireFile, libibverbs_mlnx }:

stdenv.mkDerivation rec {
  name = "librdmacm-41mlnx1";

  src = requireFile {
    name = "${name}.tar.gz";
    url = "file:///localhost";
    sha256 = "49fc95b182cd94c410acdc213f0dff2ee763f528d5fb7bb7b6b6a4ac13591686";
  };

  buildInputs = [ libibverbs_mlnx ];

  meta = with stdenv.lib; {
    homepage = https://www.openfabrics.org/;
    platforms = with platforms; linux ++ freebsd;
    license = licenses.bsd2;
    maintainers = with maintainers; [ wkennington ];
  };
}
