{ stdenv, fetchurl, pkgconfig, intltool, iconnamingutils, librsvg, hicolor_icon_theme, gtk3 }:

stdenv.mkDerivation rec {
  name = "mate-icon-theme-${version}";
  version = "${major-ver}.${minor-ver}";
  major-ver = "1.17";
  minor-ver = "0";

  src = fetchurl {
    url = "http://pub.mate-desktop.org/releases/${major-ver}/${name}.tar.xz";
    sha256 = "1kxpckaksaz5g3c4jjkh4pdm9yhbjda5835am3wg2iyy2p7rjn8n";
  };

  nativeBuildInputs = [ pkgconfig intltool iconnamingutils ];

  buildInputs = [ librsvg hicolor_icon_theme ];
  
  postInstall = ''
    for theme in "$out"/share/icons/*; do
      "${gtk3.out}/bin/gtk-update-icon-cache" "$theme"
    done
  '';
  
  meta = {
    description = "Icon themes from MATE";
    homepage = "http://mate-desktop.org";
    license = stdenv.lib.licenses.lgpl3;
    platforms = stdenv.lib.platforms.unix;
    maintainers = [ stdenv.lib.maintainers.romildo ];
  };
}
