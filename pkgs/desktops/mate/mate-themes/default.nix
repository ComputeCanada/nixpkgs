{ stdenv, fetchurl, pkgconfig, intltool, mate, gnome3, gtk2, gtk_engines,
  gtk-engine-murrine, gdk_pixbuf, librsvg }:

stdenv.mkDerivation rec {
  name = "mate-themes-${version}";
  version = "${major-ver}.${minor-ver}";
  major-ver = gnome3.version;
  minor-ver = {
    "3.20" = "23";
    "3.22" = "14";
  }."${major-ver}";

  src = fetchurl {
    url = "http://pub.mate-desktop.org/releases/themes/${major-ver}/${name}.tar.xz";
    sha256 = {
      "3.20" = "0xmcm1kmkhbakhwy5vvx3gll5v2gvihwnbf0gyjf75fys6h3818g";
      "3.22" = "09fqvlnmrvc73arl7jv9ygkxi46lw7c1q8qra6w3ap7x83f9zdak";
    }."${major-ver}";
  };

  nativeBuildInputs = [ pkgconfig intltool ];

  buildInputs = [ mate.mate-icon-theme gtk2 gtk_engines gtk-engine-murrine
    gdk_pixbuf librsvg ];

  meta = {
    description = "A set of themes from MATE";
    homepage = "http://mate-desktop.org";
    license = stdenv.lib.licenses.lgpl21;
    platforms = stdenv.lib.platforms.unix;
    maintainers = [ stdenv.lib.maintainers.romildo ];
  };
}
