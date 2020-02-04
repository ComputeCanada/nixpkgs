{ stdenv }:

let
  name = "glibc-symlinks-${version}";
  version = "1.0";

in
stdenv.mkDerivation {
  inherit name;
  inherit version;

  unpackPhase = "true";
  installPhase = ''
    mkdir -p "$out"/bin
    ln -s /sbin/ldconfig "$out"/bin
  '';
}
