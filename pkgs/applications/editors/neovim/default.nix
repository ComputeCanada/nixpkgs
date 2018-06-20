{ stdenv, fetchFromGitHub, cmake, libtool, pkgconfig, man
, gettext, libmsgpack, libtermkey, libuv, luaPackages, ncurses, perl
, unibilium, vimUtils, xsel, gperf, makeWrapper, luajit

, withPython ? true, pythonPackages, extraPythonPackages ? []
, withPython3 ? true, python3Packages, extraPython3Packages ? []
, withJemalloc ? true, jemalloc

, withPyGUI ? false
, vimAlias ? false
, configure ? null
}:

with stdenv.lib;

let

  # Note: this is NOT the libvterm already in nixpkgs, but some NIH silliness:
  neovimLibvterm = stdenv.mkDerivation rec {
    name = "neovim-libvterm-${version}";
    version = "2018-06-20";

    src = fetchFromGitHub {
      owner = "neovim";
      repo = "libvterm";
      rev = "005845cd58ca409a970d822b74e1a02a503d32e7";
      sha256 = "14yv4y684pv59p7lm8c402fri7lsnpy7knpnapbwp80mf7kjirwp";
    };

    buildInputs = [ perl ];
    nativeBuildInputs = [ libtool ];

    makeFlags = [ "PREFIX=$(out)" ];

    enableParallelBuilding = true;

    meta = {
      description = "VT220/xterm/ECMA-48 terminal emulator library";
      homepage = http://www.leonerd.org.uk/code/libvterm/;
      license = licenses.mit;
      maintainers = with maintainers; [ nckx garbas ];
      platforms = platforms.unix;
    };
  };

  pythonEnv = pythonPackages.python.buildEnv.override {
    extraLibs = (
        if withPyGUI
          then [ pythonPackages.neovim_gui ]
          else [ pythonPackages.neovim ]
      ) ++ extraPythonPackages;
    ignoreCollisions = true;
  };

  python3Env = python3Packages.python.buildEnv.override {
    extraLibs = [ python3Packages.neovim ] ++ extraPython3Packages;
    ignoreCollisions = true;
  };

  neovim = stdenv.mkDerivation rec {
    name = "neovim-${version}";
    version = "0.3.0";

    src = fetchFromGitHub {
      owner = "neovim";
      repo = "neovim";
      rev = "v${version}";
      sha256 = "10c8y309fdwvr3d9n6vm1f2c0k6pzicnhc64l2dvbw1lnabp04vv";
    };

    enableParallelBuilding = true;

    buildInputs = [
      libtermkey
      libuv
      libmsgpack
      neovimLibvterm
      unibilium
      luajit
      luaPackages.lua
      gperf
    ] ++ optional withJemalloc jemalloc
      ++ lualibs;

    nativeBuildInputs = [
      cmake
      gettext
      ncurses
      makeWrapper
      pkgconfig
    ];

    LUA_PATH = stdenv.lib.concatStringsSep ";" (map luaPackages.getLuaPath lualibs);
    LUA_CPATH = stdenv.lib.concatStringsSep ";" (map luaPackages.getLuaCPath lualibs);

    lualibs = [ luaPackages.mpack luaPackages.lpeg luaPackages.luabitop ];

    cmakeFlags = [
      "-DLUA_PRG=${luaPackages.lua}/bin/lua"
    ];

    # triggers on buffer overflow bug while running tests
    hardeningDisable = [ "fortify" ];

    preConfigure = ''
      substituteInPlace runtime/autoload/man.vim \
        --replace /usr/bin/man ${man}/bin/man
    '';

    postInstall = optionalString withPython ''
      ln -s ${pythonEnv}/bin/python $out/bin/nvim-python
    '' + optionalString withPyGUI ''
      makeWrapper "${pythonEnv}/bin/pynvim" "$out/bin/pynvim" \
        --prefix PATH : "$out/bin"
    '' + optionalString withPython3 ''
      ln -s ${python3Env}/bin/python3 $out/bin/nvim-python3
    '' + optionalString (withPython || withPython3) ''
        wrapProgram $out/bin/nvim --add-flags "${
          (optionalString withPython
            ''--cmd \"let g:python_host_prog='$out/bin/nvim-python'\" '') +
          (optionalString withPython3
            ''--cmd \"let g:python3_host_prog='$out/bin/nvim-python3'\" '')
        }"
    '';

    meta = {
      description = "Vim text editor fork focused on extensibility and agility";
      longDescription = ''
        Neovim is a project that seeks to aggressively refactor Vim in order to:
        - Simplify maintenance and encourage contributions
        - Split the work between multiple developers
        - Enable the implementation of new/modern user interfaces without any
          modifications to the core source
        - Improve extensibility with a new plugin architecture
      '';
      homepage    = https://www.neovim.io;
      # "Contributions committed before b17d96 by authors who did not sign the
      # Contributor License Agreement (CLA) remain under the Vim license.
      # Contributions committed after b17d96 are licensed under Apache 2.0 unless
      # those contributions were copied from Vim (identified in the commit logs
      # by the vim-patch token). See LICENSE for details."
      license = with licenses; [ asl20 vim ];
      maintainers = with maintainers; [ manveru garbas ];
      platforms   = platforms.unix;
    };
  };

in if (vimAlias == false && configure == null) then neovim else stdenv.mkDerivation {
  name = "neovim-${neovim.version}-configured";
  inherit (neovim) version;

  nativeBuildInputs = [ makeWrapper ];

  buildCommand = ''
    mkdir -p $out/bin
    for item in ${neovim}/bin/*; do
      ln -s $item $out/bin/
    done
  '' + optionalString vimAlias ''
    ln -s $out/bin/nvim $out/bin/vim
  '' + optionalString (configure != null) ''
    wrapProgram $out/bin/nvim --add-flags "-u ${vimUtils.vimrcFile configure}"
  '';
}
