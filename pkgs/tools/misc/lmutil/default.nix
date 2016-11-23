with import <nixpkgs> {};
{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  name = "lmutil-${version}";

  version = "11.13.1.3";

  src = fetchurl {
    url = "http://transcat-plm.com/pub/tcsoft/flexnet/Linux_x64/${version}/lmutil";
    sha256 = "1hqm0qzb2k7ccg1qlypcca63b2k397nj2zxf97fjrlm9smm5mwmq";
  };

  
  unpackPhase = "true";

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/lmutil
    chmod +x $out/bin/lmutil
    chmod u+w $out/bin/lmutil
    patchelf --set-interpreter \
        ${stdenv.glibc}/lib/ld-linux-x86-64.so.2 $out/bin/lmutil
    chmod u-w $out/bin/lmutil
  '';

  meta = {
    description = "Tool querying a FlexLM server";
  };
}

