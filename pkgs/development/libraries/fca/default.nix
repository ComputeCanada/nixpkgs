{ stdenv, requireFile, rpmextract, patchelf, rdma-core, libibmad }:

stdenv.mkDerivation rec {
  version = "2.5.2431-1";
  name = "fca-${version}";

  src = requireFile {
    name = "${name}.x86_64.rpm";
    url = "file:///localhost";
    sha256 = "8de87c72dc021c234fa1e11db4d78ffea25ccac6c8ac5b18e6b71b05000c139f";
  };

  buildInputs = [ rpmextract patchelf rdma-core libibmad ];

  unpackCmd = ''
    mkdir ${name};
    cd ${name};
    ${rpmextract}/bin/rpmextract $src;
    cd ..;
  '';

  installPhase = ''
    cd opt/mellanox/fca
    mkdir -p $out/bin $out/lib $out/include/fca/{core,config} $out/share/doc/fca/sdk/{examples/fca1,benchmark}
    install -m755 bin/* $out/bin
    for i in $out/bin/*; do
      if [ $i != "$out/bin/shm_loop.sh" ]; then
        echo $i
        patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $i
        patchelf --set-rpath $out/lib:${rdma-core}/lib:${libibmad}/lib $i
      fi
    done
    install -m755 lib/lib*.a lib/lib*.so* $out/lib
    ln -sf libfca.so.0 $out/lib/libfca.so
    ln -sf libfca.so.0.0.0 $out/lib/libfca.so.0
    for i in $out/lib/*.so; do
      patchelf --set-rpath ${rdma-core}/lib:${libibmad}/lib $i
    done
    install -m644 include/fca/*.h $out/include/fca
    install -m644 include/fca/config/* $out/include/fca/config
    install -m644 include/fca/core/* $out/include/fca/core
    install -m644 share/doc/fca/* $out/share/doc/fca
    install -m644 sdk/benchmark/* $out/share/doc/fca/sdk/benchmark
    install -m644 sdk/examples/fca1/* $out/share/doc/fca/sdk/examples/fca1
  '';

  dontStrip = true;

  meta = with stdenv.lib; {
    homepage = https://www.mellanox.com/products/fca/;
    license = licenses.unfree;
    platforms = platforms.unix;
  };
}
