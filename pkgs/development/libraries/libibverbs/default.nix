{ stdenv, fetchurl, autoconf, automake, libtool, valgrind, pkgconfig, libnl }:

let

  verbs = rec {
      version = "1.2.1";
      name = "libibverbs-${version}";
      url = "http://downloads.openfabrics.org/verbs/${name}.tar.gz";
      sha256 = "c352a7f24e9a9d30ea74faa35d1b721d78d770506a0c03732e3132b7c85ac330";
  };

  drivers = {
      libmlx4 = rec { 
          version = "1.2.1";
          name = "libmlx4-${version}"; 
          url = "http://downloads.openfabrics.org/mlx4/${name}.tar.gz";
          sha256 = "64604e0bcb79f443f2348b9eb803b1af5ce38a51480be4c0d49223e84847d81e";
      };
      libmlx5 = rec {
          version = "1.2.1";
          name = "libmlx5-${version}";
          url = "http://downloads.openfabrics.org/mlx5/${name}.tar.gz";
          sha256 = "d0551740c9a726dd3c3af88833b2540c30b489df050cf3e20b1f68058de26c62";
      };
      libmthca = rec { 
          version = "1.0.6"; 
          name = "libmthca-${version}"; 
          url = "http://downloads.openfabrics.org/mthca/${name}.tar.gz";
          sha256 = "cc8ea3091135d68233d53004e82b5b510009c821820494a3624e89e0bdfc855c";
      };
      libipathverbs = rec {
          version = "1.3";
          name = "libipathverbs-${version}";
          url = "http://downloads.openfabrics.org/libipathverbs/${name}.tar.gz";
          sha256 = "1xwjfsfjnz1j6gdiic2raycvy849hnhz7x9p9njd1z0j1gm6js0l";
      };
      opa-libhfi1verbs = rec {
          version = "10_1_2";
          name = "opa-libhfi1verbs-${version}";
          url = "https://github.com/01org/opa-libhfi1verbs/archive/${version}.tar.gz";
          sha256 = "895c7485c00331bf5d573678affa6a7436e7aae81d6f00277695b6007caa699c";
      };
  };

in stdenv.mkDerivation rec {

  inherit (verbs) name version ;

  srcs = [
    ( fetchurl { inherit (verbs) url sha256 ; } )
    ( fetchurl { inherit (drivers.libmlx4) url sha256 ; } )
    ( fetchurl { inherit (drivers.libmlx5) url sha256 ; } )
    ( fetchurl { inherit (drivers.libmthca) url sha256 ; } )
    ( fetchurl { inherit (drivers.libipathverbs) url sha256 ; } )
    ( fetchurl { inherit (drivers.opa-libhfi1verbs) url sha256 ; } )
  ];

  sourceRoot = name;

  buildInputs = [ autoconf automake libtool valgrind pkgconfig libnl ];

  # Install userspace drivers
  postInstall = ''
    for dir in ${drivers.libmlx4.name} ${drivers.libmlx5.name} ${drivers.libmthca.name} ${drivers.libipathverbs.name} ${drivers.opa-libhfi1verbs.name} ; do
      cd ../$dir
      export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -I$out/include"
      export NIX_LDFLAGS="-rpath $out/lib $NIX_LDFLAGS -L$out/lib"
      if test $dir == ${drivers.opa-libhfi1verbs.name}; then
        rm makefile && ./autogen.sh
      fi
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

