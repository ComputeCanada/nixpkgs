{ stdenv, fetchurl, perl, tcl, lua, luafilesystem, luaposix, rsync, procps }:

stdenv.mkDerivation rec {
  name = "Lmod-${version}";

  version = "7.8.13";
  src = fetchurl {
    url = "http://github.com/TACC/Lmod/archive/${version}.tar.gz";
    sha256 = "0rck5g379dbw7xdm6gp90vv4f9d65vp3f9wp6604cl9dfk23kq9c";
  };

  buildInputs = [ lua tcl perl rsync procps ];
  propagatedBuildInputs = [ luaposix luafilesystem ];
  # set custom LD_LIBRARY_PATH so capture("groups") works properly
  preConfigure = '' makeFlags="PREFIX=$out"; export LD_LIBRARY_PATH=/cvmfs/soft.computecanada.ca/nix/lib '';
  configureFlags = [ "--with-duplicatePaths=yes --with-caseIndependentSorting=yes --with-redirect=yes --with-module-root-path=/cvmfs/soft.computecanada.ca/easybuild/modules" ];

  # replace nix-store paths in the environment with nix-profile paths to allow easy upgrade
  postInstall = ''
    sed -i -e "s;/cvmfs/soft.computecanada.ca/nix/store/[^/]*;/cvmfs/soft.computecanada.ca/nix/var/nix/profiles/16.09;g" $out/lmod/lmod/init/* ;
    sed -i -e 's;/cvmfs/soft.computecanada.ca/nix/store/[^/"]*;/cvmfs/soft.computecanada.ca/nix/var/nix/profiles/16.09;g' \
    	   -e 's:/usr/share/lua/5.2/?.lua;/usr/share/lua/5.2/?/init.lua;/usr/lib/lua/5.2/?.lua;/usr/lib/lua/5.2/?/init.lua;./?.lua;::g' \
    	   -e 's:/usr/lib/lua/5.2/?.so;/usr/lib/lua/5.2/loadall.so;./?.so;::g' $(grep -rl "nix/store" $out | grep lua)
    sed -i -e 's;/cvmfs/soft.computecanada.ca/nix/store/[^/"]*;/cvmfs/soft.computecanada.ca/nix/var/nix/profiles/16.09;g' \
    	   -e 's:/usr/share/lua/5.2/?.lua;/usr/share/lua/5.2/?/init.lua;/usr/lib/lua/5.2/?.lua;/usr/lib/lua/5.2/?/init.lua;./?.lua;::g' \
    	   -e 's:/usr/lib/lua/5.2/?.so;/usr/lib/lua/5.2/loadall.so;./?.so;::g' $out/lmod/lmod/libexec/{computeHashSum,lmod,addto,spider,clearMT_cmd,ml_cmd,spiderCacheSupport,sh_to_modulefile,update_lmod_system_cache_files} $out/lmod/lmod/settarg/{settarg_cmd,targ}
  '';

  LUA_PATH="${luaposix}/share/lua/5.2/?.lua;${luaposix}/share/lua/5.2/?/init.lua;;";
  LUA_CPATH="${luafilesystem}/lib/lua/5.2/?.so;${luaposix}/lib/lua/5.2/?.so;;";
  meta = {
    description = "Tool for configuring environments";
  };
}
