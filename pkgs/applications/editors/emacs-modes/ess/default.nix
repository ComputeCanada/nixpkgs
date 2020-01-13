{ stdenv, fetchurl, emacs, texinfo, perl }:

stdenv.mkDerivation rec {
  name = "ess-18.10.2";

  src = fetchurl {
    url = "http://ess.r-project.org/downloads/ess/${name}.tgz";
    sha256 = "1mp90kxfw3s950qvk608y10353349b8wradwma8s13b97hl44yzp";
  };

  buildInputs = [ emacs texinfo perl ];

  configurePhase = "makeFlags=PREFIX=$out";

  meta = {
    description = "Emacs Speaks Statistics";
    homepage = "http://ess.r-project.org/";
    license = stdenv.lib.licenses.gpl2Plus;
    hydraPlatforms = stdenv.lib.platforms.linux;
  };
}
