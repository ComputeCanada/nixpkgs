{ stdenv, fetchurl, pkgconfig
, bzip2, curl, expat, libarchive, xz, zlib
, useNcurses ? false, ncurses, useQt4 ? false, qt4
, wantPS ? false, ps ? null
}:

with stdenv.lib;

assert wantPS -> (ps != null);

let
  os = stdenv.lib.optionalString;
  majorVersion = "3.6";
  minorVersion = "3";
  version = "${majorVersion}.${minorVersion}";
in

stdenv.mkDerivation rec {
  name = "cmake-${os useNcurses "cursesUI-"}${os useQt4 "qt4UI-"}${version}";

  inherit majorVersion;

  src = fetchurl {
    url = "${meta.homepage}files/v${majorVersion}/cmake-${version}.tar.gz";
    sha256 = "7d73ee4fae572eb2d7cd3feb48971aea903bb30a20ea5ae8b4da826d8ccad5fe";
  };

  patches =
    # Don't search in non-Nix locations such as /usr, but do search in
    # Nixpkgs' Glibc.
    optional (stdenv ? glibc) ./search-path-3.2.patch
    ++ optional stdenv.isCygwin ./3.2.2-cygwin.patch;

  outputs = [ "out" ];
  setOutputFlags = false;

  setupHook = ./setup-hook.sh;

  buildInputs =
    [ setupHook pkgconfig bzip2 curl expat libarchive xz zlib ]
    ++ optional useNcurses ncurses
    ++ optional useQt4 qt4;

  propagatedBuildInputs = optional wantPS ps;

  preConfigure = with stdenv; optionalString (stdenv ? glibc)
    ''
      fixCmakeFiles .
      substituteInPlace Modules/Platform/UnixPaths.cmake \
        --subst-var-by glibc_bin ${getBin glibc} \
        --subst-var-by glibc_dev ${getDev glibc} \
        --subst-var-by glibc_lib ${getLib glibc}
      substituteInPlace Modules/FindCxxTest.cmake \
        --replace "$""{PYTHON_EXECUTABLE}" ${stdenv.shell}
    '';
  configureFlags =
    [ "--docdir=share/doc/${name}"
      "--no-system-jsoncpp"
    ]
    ++ optional (!stdenv.isCygwin) "--system-libs"
    ++ optional useQt4 "--qt-gui"
    ++ ["--"]
    ++ optional (!useNcurses) "-DBUILD_CursesDialog=OFF";

  dontUseCmakeConfigure = true;

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    homepage = http://www.cmake.org/;
    description = "Cross-Platform Makefile Generator";
    platforms = if useQt4 then qt4.meta.platforms else platforms.all;
    maintainers = with maintainers; [ urkud mornfall ttuegel ];
  };
}
