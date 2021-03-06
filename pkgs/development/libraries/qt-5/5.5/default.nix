/*

# Minor Updates

1. Edit ./fetchsrcs.sh to point to the updated URL.
2. Run ./fetchsrcs.sh.
3. Build and enjoy.

# Major Updates

1. Make a copy of this directory. (We like to keep the old version around
   for a short time after major updates.)
2. Delete the tmp/ subdirectory of the copy.
3. Follow the minor update instructions above.
4. Package any new Qt modules, if necessary.

*/

{ pkgs

# options
, developerBuild ? false
, decryptSslTraffic ? false
}:

let inherit (pkgs) makeSetupHook makeWrapper stdenv; in

with stdenv.lib;

let

  mirror = "http://download.qt.io";
  srcs = import ./srcs.nix { inherit mirror; inherit (pkgs) fetchurl; };

  qtSubmodule = args:
    let
      inherit (args) name;
      inherit (srcs."${args.name}") version src;
      inherit (pkgs.stdenv) mkDerivation;
    in mkDerivation (args // {
      name = "${name}-${version}";
      inherit src;

      propagatedBuildInputs = args.qtInputs ++ (args.propagatedBuildInputs or []);
      nativeBuildInputs = (args.nativeBuildInputs or []) ++ [ self.qmakeHook ];

      NIX_QT_SUBMODULE = args.NIX_QT_SUBMODULE or true;

      outputs = args.outputs or [ "out" "dev" ];
      setOutputFlags = args.setOutputFlags or false;

      setupHook = ./setup-hook.sh;

      enableParallelBuilding = args.enableParallelBuilding or true;

      meta = self.qtbase.meta // (args.meta or {});
    });

  addPackages = self: with self;
    let
      callPackage = self.newScope { inherit qtSubmodule srcs; };
    in {

      qtbase = callPackage ./qtbase {
        mesa = pkgs.libGL;
        harfbuzz = pkgs.harfbuzz-icu;
        cups = if stdenv.isLinux then pkgs.cups else null;
        # GNOME dependencies are not used unless gtkStyle == true
        inherit (pkgs.gnome) libgnomeui GConf gnome_vfs;
        bison = pkgs.bison2; # error: too few arguments to function 'int yylex(...
        inherit developerBuild decryptSslTraffic;
      };

      /* qt3d = not packaged */
      /* qtactiveqt = not packaged */
      /* qtandroidextras = not packaged */
      /* qtcanvas3d = not packaged */
      qtconnectivity = callPackage ./qtconnectivity.nix {};
      qtdeclarative = callPackage ./qtdeclarative {};
      qtdoc = callPackage ./qtdoc.nix {};
      qtenginio = callPackage ./qtenginio.nix {};
      qtgraphicaleffects = callPackage ./qtgraphicaleffects.nix {};
      qtimageformats = callPackage ./qtimageformats.nix {};
      qtlocation = callPackage ./qtlocation.nix {};
      /* qtmacextras = not packaged */
      qtmultimedia = callPackage ./qtmultimedia.nix {
        inherit (pkgs.gst_all_1) gstreamer gst-plugins-base;
      };
      qtquick1 = callPackage ./qtquick1 {};
      qtquickcontrols = callPackage ./qtquickcontrols.nix {};
      qtscript = callPackage ./qtscript {};
      qtsensors = callPackage ./qtsensors.nix {};
      qtserialport = callPackage ./qtserialport {};
      qtsvg = callPackage ./qtsvg.nix {};
      qttools = callPackage ./qttools {};
      qttranslations = callPackage ./qttranslations.nix {};
      /* qtwayland = not packaged */
      /* qtwebchannel = not packaged */
      /* qtwebengine = not packaged */
      qtwebkit = callPackage ./qtwebkit {};
      qtwebkit-examples = callPackage ./qtwebkit-examples.nix {};
      qtwebsockets = callPackage ./qtwebsockets.nix {};
      /* qtwinextras = not packaged */
      qtx11extras = callPackage ./qtx11extras.nix {};
      qtxmlpatterns = callPackage ./qtxmlpatterns.nix {};

      env = callPackage ../qt-env.nix {};
      full = env "qt-${qtbase.version}" [
        qtconnectivity qtdeclarative qtdoc qtenginio qtgraphicaleffects qtimageformats
        qtlocation qtmultimedia qtquick1 qtquickcontrols qtscript qtsensors qtserialport
        qtsvg qttools qttranslations qtwebkit qtwebkit-examples qtwebsockets qtx11extras
        qtxmlpatterns
      ];

      makeQtWrapper = makeSetupHook { deps = [ makeWrapper ]; } ./make-qt-wrapper.sh;
      qmakeHook = makeSetupHook { substitutions = { qt_dev = qtbase.dev; lndir = pkgs.xorg.lndir; }; } ./qmake-hook.sh;

    };

   self = makeScope pkgs.newScope addPackages;

in self
