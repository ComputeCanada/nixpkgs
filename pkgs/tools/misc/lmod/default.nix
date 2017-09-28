{ stdenv, fetchurl, perl, tcl, lua, luafilesystem, luaposix, rsync, procps }:

stdenv.mkDerivation rec {
  name = "Lmod-${version}";

  version = "7.5.11";
  src = fetchurl {
    url = "http://github.com/TACC/Lmod/archive/${version}.tar.gz";
    sha256 = "0ln5daayk0z89fm9q26572c66qxzja6868vagsz7rqmbl97bmbn8";
  };

  buildInputs = [ lua tcl perl rsync procps ];
  propagatedBuildInputs = [ luaposix luafilesystem ];
  # set custom LD_LIBRARY_PATH so capture("groups") works properly
  preConfigure = '' makeFlags="PREFIX=$out"; export LD_LIBRARY_PATH=/cvmfs/soft.computecanada.ca/nix/lib '';
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
