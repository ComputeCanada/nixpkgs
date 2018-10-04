{ lib
, cffi
, six
, hypothesis
, pytest
, wheel
, buildPythonPackage
, fetchurl
}:

buildPythonPackage rec {
  pname = "argon2_cffi";
  version = "16.3.0";
  name    = "${pname}-${version}";

  src = fetchurl {
    url = "mirror://pypi/a/argon2_cffi/${name}.tar.gz";
    sha256 = "1ap3il3j1pjyprrhpfyhc21izpmhzhfb5s69vlzc65zvd1nj99cr";
  };

  propagatedBuildInputs = [ cffi six ];
  checkInputs = [ hypothesis pytest wheel ];

  meta = {
    description = "Secure Password Hashes for Python";
    homepage    = https://argon2-cffi.readthedocs.io/;
  };
}
