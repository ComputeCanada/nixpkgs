{ stdenv, fetchurl, rpmextract, patchelf, rdma-core, zlib }:

stdenv.mkDerivation rec {
  version = "3.5.3094-1";
  name = "mxm-${version}";

  src = fetchurl {
    url = "http://bgate.mellanox.com/mxm/mxm/RHEL-6.8/${name}.x86_64.rpm";
    sha256 = "dec59a8a5e4e7b600d7d8d819b72df91c986afd1f37cd442100d563f6bc0d001";
  };

  buildInputs = [ rpmextract patchelf rdma-core zlib ];

  unpackCmd = ''
    mkdir ${name};
    cd ${name};
    ${rpmextract}/bin/rpmextract $src;
    cd ..;
  '';

  installPhase = ''
    cd opt/mellanox/mxm
    mkdir -p $out/bin $out/lib $out/include/mxm/api $out/share/doc/mxm $out/share/doc/examples/perftest
    install -m755 bin/* $out/bin
    for i in $out/bin/*; do
      patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $i
      patchelf --set-rpath $out/lib:${rdma-core}/lib:${zlib}/lib $i
    done
    install -m755 lib/lib*.a lib/lib*.so* $out/lib
    ln -sf libmxm.so.2 $out/lib/libmxm.so
    ln -sf libmxm.so.2.0.32 $out/lib/libmxm.so.2
    for i in $out/lib/*.so; do
      patchelf --set-rpath ${rdma-core}/lib:${zlib}/lib $i
    done
    install -m644 include/mxm/api/* $out/include/mxm/api
    install -m644 share/doc/mxm/* $out/share/doc/mxm
    install -m644 examples/perftest/* $out/share/doc/examples/perftest
  '';

  dontStrip = true;

  meta = with stdenv.lib; {
    homepage = https://www.mellanox.com/products/mxm/;
    license = licenses.unfree;
    platforms = platforms.unix;
  };
}
