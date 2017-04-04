{ stdenv, fetchurl, cmake, mesa_noglu, mesa_glu, freeglut, zlib, libpng
, texlive, libXmu, libXi,
}:

stdenv.mkDerivation rec {
  name = "gl2ps-1.4.0";

  src = fetchurl {
    url = "http://geuz.org/gl2ps/src/${name}.tgz";
    sha256 = "1qpidkz8x3bxqf69hlhyz1m0jmfi9kq24fxsp7rq6wfqzinmxjq3";
  };

  outputs = [ "out" "dev" ];
  buildInputs = [ cmake mesa_noglu mesa_glu freeglut zlib libpng texlive.combined.scheme-basic libXmu libXi ];

  meta = with stdenv.lib; {
    description = "An OpenGL to PostScript printing library";
    homepage = http://www.geuz.org/gl2ps/;
    license = licenses.lgpl2;
  };
}
