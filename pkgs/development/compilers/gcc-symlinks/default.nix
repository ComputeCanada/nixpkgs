{stdenv, gfortran48, gfortran5, gfortran6, gfortran7, gfortran8}:

let
  name = "gccruntime-${version}";
  version = "1.0.1";

in
stdenv.mkDerivation {
  inherit name;
  inherit version;

  unpackPhase = "true";
  installPhase = ''
    mkdir -p "$out"/lib
    for i in ${gfortran48.cc.lib}/lib/lib*.so.*; do
      ln -sf $i "$out"/lib
    done 
    for i in ${gfortran5.cc.lib}/lib/lib*.so.*; do
      ln -sf $i "$out"/lib
    done 
    for i in ${gfortran6.cc.lib}/lib/lib*.so.*; do
      ln -sf $i "$out"/lib
    done 
    for i in ${gfortran7.cc.lib}/lib/lib*.so.*; do
      ln -sf $i "$out"/lib
    done
    for i in ${gfortran8.cc.lib}/lib/lib*.so.*; do
      ln -sf $i "$out"/lib
    done
    ln -s ${gfortran5.cc}/bin "$out"/bin
    ln -s ${gfortran5.cc}/share "$out"/share
  '';
}
