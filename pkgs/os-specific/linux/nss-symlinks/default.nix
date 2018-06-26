{ stdenv }:

let
  name = "nss-symlinks-${version}";
  version = "1.0";

in
stdenv.mkDerivation {
  inherit name;
  inherit version;

  unpackPhase = "true";
  installPhase = ''
    mkdir -p "$out"/lib
    ln -s /lib64/libnss_ldap.so.2 "$out"/lib
    ln -s /lib64/libnss_sss.so.2 "$out"/lib
  '';
}
