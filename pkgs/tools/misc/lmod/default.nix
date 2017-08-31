{ stdenv, fetchurl, perl, tcl, lua, luafilesystem, luaposix, rsync, procps }:

stdenv.mkDerivation rec {
  name = "Lmod-${version}";

  version = "7.6.11";
  src = fetchurl {
    url = "http://github.com/TACC/Lmod/archive/${version}.tar.gz";
    sha256 = "107w3m8w4amj7vvyqr35200gd7abghmr9swjlfv7w8h1sfaxyxl4";
  };

  buildInputs = [ lua tcl perl rsync procps ];
  propagatedBuildInputs = [ luaposix luafilesystem ];
  preConfigure = '' makeFlags="PREFIX=$out" '';
  configureFlags = [ "--with-duplicatePaths=yes --with-caseIndependentSorting=yes --with-redirect=yes --with-module-root-path=/cvmfs/soft.computecanada.ca/easybuild/modules" ];

  # replace nix-store paths in the environment with nix-profile paths to allow easy upgrade
  postInstall = ''
    sed -i -e "s;/cvmfs/soft.computecanada.ca/nix/store/[^/]*;/cvmfs/soft.computecanada.ca/nix/var/nix/profiles/16.09;g" $out/lmod/lmod/init/* 
  '';

  LUA_PATH="${luaposix}/share/lua/5.2/?.lua;${luaposix}/share/lua/5.2/?/init.lua;;";
  LUA_CPATH="${luafilesystem}/lib/lua/5.2/?.so;${luaposix}/lib/lua/5.2/?.so;;";
  meta = {
    description = "Tool for configuring environments";
  };
}
