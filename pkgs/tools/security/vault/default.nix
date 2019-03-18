{ stdenv, lib, buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  name = "vault-${version}";
  version = "1.0.3";

  goPackagePath = "github.com/hashicorp/vault";

  src = fetchFromGitHub {
    owner = "hashicorp";
    repo = "vault";
    rev = "v${version}";
    sha256 = "6ece62b75265a963ac70981c529ea82f2383ea4fdef47fdb14953aff22bfff6c";
  };

  buildFlagsArray = ''
    -ldflags=
      -X github.com/hashicorp/vault/version.GitCommit=${version}
  '';

  meta = with stdenv.lib; {
    homepage = https://www.vaultproject.io;
    description = "A tool for managing secrets";
    license = licenses.mpl20;
    maintainers = [ maintainers.rushmorem ];
  };
}
