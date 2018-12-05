{ stdenv, requireFile, patchelf, rdma-core, ucx }:

stdenv.mkDerivation rec {
  version = "4.2.2554";
  name = "hcoll-${version}";

  src = requireFile {
    name = "${name}.tar.gz";
    url = "file:///localhost";
    sha256 = "98f0348932c4d5e9e709267d78ba470989e8b0141a6dd6f994b1e1e8a13661cc";
  };

  buildInputs = [ patchelf rdma-core ucx ];

  unpackCmd = ''
    mkdir ${name};
    cd ${name};
    tar xvf $src;
    cd ..;
  '';

  installPhase = ''
    cd hcoll
    mkdir -p $out/bin $out/lib/hcoll $out/etc/hcoll $out/share/hcoll $out/share/doc/hcoll
    install -m755 bin/* $out/bin
    install -m755 lib/lib*.a lib/lib*.so.*.* $out/lib
    install -m755 lib/hcoll/* $out/lib/hcoll
    find include/ -type f -exec install -Dm 755 "{}" $out/"{}" \;
    install -m644 etc/* $out/etc/hcoll
    install -m644 share/hcoll/* $out/share/hcoll
    install -m644 share/doc/hcoll/* $out/share/doc/hcoll
    cd $out/lib
    ln -s libalog.so.*.* libalog.so.1
    ln -s libalog.so.*.* libalog.so
    ln -s libhcoll.so.*.* libhcoll.so.1
    ln -s libhcoll.so.*.* libhcoll.so
    ln -s libocoms.so.*.* libocoms.so.0
    ln -s libocoms.so.*.* libocoms.so  
  '';


  postFixup = ''
    for i in $out/bin/*; do
      patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $i
      patchelf --set-rpath $out/lib:${rdma-core}/lib:${ucx}/lib $i
    done
    for i in $out/lib/lib*.so.*.*; do
      patchelf --set-rpath $out/lib:${rdma-core}/lib:${ucx}/lib $i
    done
  '';

  dontStrip = true;

  meta = with stdenv.lib; {
    homepage = https://www.mellanox.com/products/mxm/;
    license = licenses.unfree;
    platforms = platforms.unix;
  };
}
