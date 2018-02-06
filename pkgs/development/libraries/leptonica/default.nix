{stdenv, fetchurl, libpng, libtiff, libjpeg, zlib}:

stdenv.mkDerivation {
  name = "leptonica-1.75";

  src = fetchurl {
    url = http://www.leptonica.org/source/leptonica-1.75.1.tar.gz;
    sha256 = "0cd8fzs9bqkqs1fmdr6gd3c6q5fpqd456rqk922dki6ldqr04m1w";
  };

  buildInputs = [ libpng libtiff libjpeg zlib ];

  meta = {
    description = "Image processing and analysis library";
    homepage = http://www.leptonica.org/;
    # Its own license: http://www.leptonica.org/about-the-license.html
    license = stdenv.lib.licenses.free;
    platforms = stdenv.lib.platforms.unix;
  };
}
