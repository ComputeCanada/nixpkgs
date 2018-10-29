{ stdenv, pythonPackages, fetchurl }:
with pythonPackages; buildPythonApplication rec {
  pname = "pre_commit";
  version = "1.10.4";
  name = "${pname}-${version}";

  src = fetchurl {
    url = "mirror://pypi/p/${pname}/${name}.tar.gz";
    sha256 = "1kn8h9k9ca330m5n7r4cvxp679y3sc95m1x23a3qhzgam09n7jwr";
  };

  propagatedBuildInputs = [
    aspy-yaml
    cached-property
    cfgv
    identify
    nodeenv
    pyyaml
    six
    toml
    virtualenv
  ];

  # Tests fail due to a missing windll dependency
  doCheck = false;

  meta = with stdenv.lib; {
    description = "A framework for managing and maintaining multi-language pre-commit hooks";
    homepage = https://pre-commit.com/;
    license = licenses.mit;
    maintainers = with maintainers; [ borisbabic ];
  };
}
