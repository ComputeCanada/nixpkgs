{ stdenv, fetchurl, autoconf, automake, libtool, valgrind, pkgconfig, libnl, requireFile }:

let

  verbs = rec {
      version = "41mlnx1";
      name = "libibverbs-${version}";
      url = "file:///${name}.tar.gz";
      sha256 = "35b436fcbf5b625ae3ee9fe72c6b40d048b1d5231f23521d02095e7fc7721e2d";
  };

  drivers = {
      libmlx4 = rec {
          version = "41mlnx1";
          name = "libmlx4-${version}"; 
          url = "file:///${name}.tar.gz";
          sha256 = "8bdf808c6fc0c070314b38fc517def84b56c1991ef2bdd302d075cc260e943c0";
      };
      libmlx5 = rec {
          version = "41mlnx1";
          name = "libmlx5-${version}";
          url = "file:///${name}.tar.gz";
          sha256 = "fb14d97db32f249e7f96382b71b69dda7e722a455b52a44c263830a4f7658730";
      };
  };

in stdenv.mkDerivation rec {

  inherit (verbs) name version ;

  srcs = [
    ( requireFile { inherit (verbs) url sha256 ; } )
    ( requireFile { inherit (drivers.libmlx4) url sha256 ; } )
    ( requireFile { inherit (drivers.libmlx5) url sha256 ; } )
  ];

  sourceRoot = name;

  buildInputs = [ autoconf automake libtool valgrind pkgconfig libnl ];

  # Install userspace drivers
  postInstall = ''
    for dir in ${drivers.libmlx4.name} ${drivers.libmlx5.name} ; do 
      cd ../$dir
      export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -I$out/include"
      export NIX_LDFLAGS="-rpath $out/lib $NIX_LDFLAGS -L$out/lib"
      ./configure $configureFlags
      make -j$NIX_BUILD_CORES
      make install
    done

    mkdir -p $out/lib/pkgconfig
    cat >$out/lib/pkgconfig/ibverbs.pc <<EOF
    prefix=$out
    exec_prefix=\''${prefix}
    libdir=\''${exec_prefix}/lib
    includedir=\''${prefix}/include

    Name: IB verbs
    Version: ${version}
    Description: Library for direct userspace use of RDMA (InfiniBand/iWARP)
    Libs: -L\''${libdir} -libverbs
    Cflags: -I\''${includedir}
    EOF
  '';

  # Re-add the libibverbs path into runpath of the library
  # to enable plugins to be found by dlopen
  postFixup = ''
    RPATH=$(patchelf --print-rpath $out/lib/libibverbs.so)
    patchelf --set-rpath $RPATH:$out/lib $out/lib/libibverbs.so.1.0.0
  '';

  meta = with stdenv.lib; {
    homepage = https://www.openfabrics.org/;
    license = licenses.bsd2;
    platforms = with platforms; linux ++ freebsd;
    maintainers = with maintainers; [ wkennington bzizou ];
  };
}

