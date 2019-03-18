with import <nixpkgs> {};
{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  name = "vault_${version}_linux_amd64";

  version = "1.0.3";

  src = fetchurl {
    url = " https://releases.hashicorp.com/vault/${version}";
    sha256 = "a475946872b1a4a2bd8ea79ea1dd00fe65aa502f45d734a07afc022bf2ba8bcf";
  };

  
  unpackPhase = "true";

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/vault
    chmod +x $out/bin/vault
    chmod u+w $out/bin/vault
    chmod u-w $out/bin/vault
  '';

  meta = {
    description = "Manage Secrets and Protect Sensitive Data";
  };
}

