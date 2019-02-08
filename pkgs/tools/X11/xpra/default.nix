{ stdenv, lib, fetchurl, callPackage, substituteAll, pythonPackages, pkgconfig, writeText
, xorg, gtk, glib, pango, cairo, gdk_pixbuf, atk
, makeWrapper, xkbcomp, xorgserver, getopt, xauth, utillinux, which, fontsConf, xkeyboard_config
, ffmpeg, x264, libvpx, libwebp
, libfakeXinerama }:

let
  inherit (pythonPackages) python cython buildPythonApplication;
  xf86videodummy = callPackage ./xf86videodummy { };
in buildPythonApplication rec {
  name = "xpra-2.4.3";
  namePrefix = "";
  src = fetchurl {
    url = "http://xpra.org/src/${name}.tar.xz";
    sha256 = "0pq2pzmv5fsafp50rzl9nb6ns08rl88fhgdqc2hh27dx7b8ka8n6";
  };

  patches = [
    (substituteAll {
      src = ./fix-paths.patch;
      inherit (xorg) xkeyboardconfig;
    })
  ];

  buildInputs = [
    cython pkgconfig

    xorg.libX11 xorg.renderproto xorg.libXrender xorg.libXi xorg.inputproto xorg.kbproto
    xorg.randrproto xorg.damageproto xorg.compositeproto xorg.xextproto xorg.recordproto
    xorg.xproto xorg.fixesproto xorg.libXtst xorg.libXfixes xorg.libXcomposite xorg.libXdamage
    xorg.libXrandr xorg.libxkbfile

    pango cairo gdk_pixbuf atk gtk glib

    ffmpeg libvpx x264 libwebp

    makeWrapper
  ];

  propagatedBuildInputs = with pythonPackages; [
    pillow pygtk pygobject rencode pycrypto cryptography pycups lz4 dbus-python
  ];

  preBuild = ''
    export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE $(pkg-config --cflags gtk+-2.0) $(pkg-config --cflags pygtk-2.0) $(pkg-config --cflags xtst)"
    substituteInPlace xpra/x11/bindings/keyboard_bindings.pyx --replace "/usr/share/X11/xkb" "${xorg.xkeyboardconfig}/share/X11/xkb"
  '';
  setupPyBuildFlags = ["--with-Xdummy" "--without-strict"];

  preInstall = ''
    # see https://bitbucket.org/pypa/setuptools/issue/130/install_data-doesnt-respect-prefix
    ${python}/bin/${python.executable} setup.py install_data --install-dir=$out --root=$out
    sed -i '/ = data_files/d' setup.py
  '';

  xorgConfig = writeText "10-dummy.conf" ''
    Section "Module"
      Load "fb"
    EndSection
    Section "Files"
      ModulePath "${xorg.xorgserver.out}/lib/xorg/modules"
      ModulePath "${xorg.xf86videodummy}/lib/xorg/modules"
      XkbDir "${xkeyboard_config}/share/X11/xkb"

      FontPath "${xorg.fontadobe75dpi}/lib/X11/fonts/75dpi"
      FontPath "${xorg.fontadobe100dpi}/lib/X11/fonts/100dpi"
      FontPath "${xorg.fontbhlucidatypewriter75dpi}/lib/X11/fonts/75dpi"
      FontPath "${xorg.fontbhlucidatypewriter100dpi}/lib/X11/fonts/100dpi"
      FontPath "${xorg.fontbh100dpi}/lib/X11/fonts/100dpi"
      FontPath "${xorg.fontmiscmisc}/lib/X11/fonts/misc"
      FontPath "${xorg.fontcursormisc}/lib/X11/fonts/misc"
    EndSection
  '';

  postInstall = ''
    cp ${xorgConfig} $out/etc/X11/xorg.conf.d
    wrapProgram $out/bin/xpra \
      --set XKB_BINDIR "${xkbcomp}/bin" \
      --set FONTCONFIG_FILE "${fontsConf}" \
      --set XPRA_LOG_DIR "\$HOME/.xpra" \
      --set XPRA_INSTALL_PREFIX "$out" \
      --prefix LD_LIBRARY_PATH : ${libfakeXinerama}/lib \
      --prefix PATH : ${stdenv.lib.makeBinPath [ getopt xorgserver xauth which utillinux ]}
  '';

  preCheck = "exit 0";

  #TODO: replace postInstall with postFixup to avoid double wrapping of xpra; needs more work though
  #postFixup = ''
  #  sed -i '2iexport XKB_BINDIR="${xkbcomp}/bin"' $out/bin/xpra
  #  sed -i '3iexport FONTCONFIG_FILE="${fontsConf}"' $out/bin/xpra
  #  sed -i '4iexport PATH=${stdenv.lib.makeBinPath [ getopt xorgserver xauth which utillinux ]}\${PATH:+:}\$PATH' $out/bin/xpra
  #'';

  passthru = { inherit xf86videodummy; };

  meta = {
    homepage = http://xpra.org/;
    description = "Persistent remote applications for X";
    platforms = stdenv.lib.platforms.linux;
    license = stdenv.lib.licenses.gpl2;
    maintainers = with stdenv.lib.maintainers; [ tstrobel offline numinit ];
  };
}
