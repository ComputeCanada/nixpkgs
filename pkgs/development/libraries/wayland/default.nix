{ lib, stdenv, fetchurl, pkgconfig
, libffi, docbook_xsl, doxygen, graphviz, libxslt, xmlto, libxml2
, expat ? null # Build wayland-scanner (currently cannot be disabled as of 1.7.0)
}:

# Require the optional to be enabled until upstream fixes or removes the configure flag
assert expat != null;

stdenv.mkDerivation rec {
  name = "wayland-${version}";
  version = "1.15.0";

  src = fetchurl {
    url = "http://wayland.freedesktop.org/releases/${name}.tar.xz";
    sha256 = "9540925f7928becfdf5e3b84c70757f6589bf1ceef09bea78784d8e4772c0db0";
  };

  configureFlags = "--with-scanner --disable-documentation";

  nativeBuildInputs = [ pkgconfig ];

  buildInputs = [ libffi /* docbook_xsl doxygen graphviz libxslt xmlto */ expat libxml2 ];

  meta = {
    description = "Reference implementation of the wayland protocol";
    homepage    = http://wayland.freedesktop.org/;
    license     = lib.licenses.mit;
    platforms   = lib.platforms.linux;
    maintainers = with lib.maintainers; [ codyopel wkennington ];
  };

  passthru.version = version;
}
