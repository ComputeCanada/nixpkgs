{ stdenv, fetchurl, perl, tcl, lua, luafilesystem, luaposix, rsync, procps }:

stdenv.mkDerivation rec {
  name = "Lmod-${version}";

  version = "7.3.2";
  src = fetchurl {
    url = "http://github.com/TACC/Lmod/archive/${version}.tar.gz";
    sha256 = "1f01mz27nqia6v0666v512b0f5r0dc1fxjvacpaijnyf6fgjag5k";
  };

  buildInputs = [ lua tcl perl rsync procps ];
  propagatedBuildInputs = [ luaposix luafilesystem ];
  preConfigure = '' makeFlags="PREFIX=$out" '';
  configureFlags = [ "--with-duplicatePaths=yes --with-caseIndependentSorting=yes --with-redirect=yes --with-module-root-path=/cvmfs/soft.cc/nix/1/easybuild/generic/modules" ];

  LUA_PATH="${luaposix}/share/lua/5.2/?.lua;${luaposix}/share/lua/5.2/?/init.lua;;";
  LUA_CPATH="${luafilesystem}/lib/lua/5.2/?.so;${luaposix}/lib/lua/5.2/?.so;;";
  meta = {
    description = "Tool for configuring environments";
  };
}
