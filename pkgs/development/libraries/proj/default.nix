{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  name = "proj-${version}";
  version = "4.9.3";

  src = fetchurl {
    url = "http://download.osgeo.org/proj/${name}.tar.gz";
    sha256 = "1xw5f427xk9p2nbsj04j6m5zyjlyd66sbvl2bkg8hd1kx8pm9139";
  };

  doCheck = true;

  meta = with stdenv.lib; {
    description = "Cartographic Projections Library";
    homepage = http://trac.osgeo.org/proj/;
    license = licenses.mit;
    platforms = platforms.linux ++ platforms.darwin;
    maintainers = with maintainers; [ vbgl ];
  };
}
