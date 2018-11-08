{ stdenv, fetchurl, pkgconfig, intltool, xtrans, dbus_glib, systemd, gvfs,
  libSM, libXtst, gtk3, mate-desktop, hicolor_icon_theme,
  wrapGAppsHook
}:

stdenv.mkDerivation rec {
  name = "mate-session-manager-${version}";
  version = "${major-ver}.${minor-ver}";
  major-ver = "1.18";
  minor-ver = "2";

  src = fetchurl {
    url = "http://pub.mate-desktop.org/releases/${major-ver}/${name}.tar.xz";
    sha256 = "11ii7azl8rn9mfymcmcbpysyd12vrxp4s8l3l6yk4mwlr3gvzxj0";
  };

  nativeBuildInputs = [
    pkgconfig
    intltool
    xtrans
    wrapGAppsHook
  ];

  buildInputs = [
    dbus_glib
    systemd
    gvfs
    libSM
    libXtst
    gtk3
    mate-desktop
    hicolor_icon_theme
  ];

  postFixup = ''
    sed -i 's!^exec !export GTK_DATA_PREFIX=$NIXUSER_PROFILE\nexec !' $out/bin/mate-session
    sed -i 's!^exec !export GTK_PATH=$NIXUSER_PROFILE/lib/gtk-3.0:$NIXUSER_PROFILE/lib/gtk-2.0\nexec !' $out/bin/mate-session
    sed -i 's!^exec !export XDG_MENU_PREFIX=mate-\nexec !' $out/bin/mate-session
    sed -i 's!^exec !export XCURSOR_PATH=~/.icons:$NIXUSER_PROFILE/share/icons\nexec !' $out/bin/mate-session
    sed -i 's!^exec !export CAJA_EXTENSION_DIRS=$CAJA_EXTENSION_DIRS''${CAJA_EXTENSION_DIRS:+:}$NIXUSER_PROFILE/lib/caja/extensions-2.0\nexec !' $out/bin/mate-session
    sed -i 's!^exec !export XDG_DATA_DIRS=$XDG_DATA_DIRS''${XDG_DATA_DIRS:+:}$NIXUSER_PROFILE/share/gsettings-schemas/caja-extensions-1.18.2\nexec !' $out/bin/mate-session
    sed -i 's!^exec !export GI_TYPELIB_PATH=$GI_TYPELIB_PATH''${GI_TYPELIB_PATH:+:}$NIXUSER_PROFILE/lib/girepository-1.0\nexec !' $out/bin/mate-session
    sed -i 's!^exec !export LD_LIBRARY_PATH=$LD_LIBRARY_PATH''${LD_LIBRARY_PATH:+:}$NIXUSER_PROFILE/lib/caja/extensions-2.0\nexec !' $out/bin/mate-session
    sed -i 's!^exec !export MATE_PANEL_APPLETS_DIR=$MATE_PANEL_APPLETS_DIR''${MATE_PANEL_APPLETS_DIR:+:}$NIXUSER_PROFILE/share/mate-panel/applets\nexec !' $out/bin/mate-session
    sed -i 's!^exec !export MATE_PANEL_EXTRA_MODULES=$MATE_PANEL_EXTRA_MODULES''${MATE_PANEL_EXTRA_MODULES:+:}$NIXUSER_PROFILE/lib/mate-panel/applets\nexec !' $out/bin/mate-session
    sed -i 's!^exec !xdg-user-dirs-update\nexec !' $out/bin/mate-session
  '';

  meta = with stdenv.lib; {
    description = "MATE Desktop session manager";
    homepage = https://github.com/mate-desktop/mate-session-manager;
    license = with licenses; [ gpl2 lgpl2 ];
    platforms = platforms.unix;
    maintainers = [ maintainers.romildo ];
  };
}
