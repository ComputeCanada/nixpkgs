{ stdenv, fetchurl, fetchpatch, python, buildPythonPackage, gmp }:

buildPythonPackage rec {
  name = "pycrypto-2.6.1";
  namePrefix = "";

  src = fetchurl {
    url = "mirror://pypi/p/pycrypto/${name}.tar.gz";
    sha256 = "0g0ayql5b9mkjam8hym6zyg6bv77lbh66rv1fyvgqb17kfc1xkpj";
  };

  patches = [
    (fetchpatch {
      name = "CVE-2013-7459.patch";
      url = "https://raw.githubusercontent.com/openembedded/meta-openembedded/master/meta-python/recipes-devtools/python/python-pycrypto/CVE-2013-7459.patch"
      sha256 = "870d6afad0e0a08a4888b99a2f935177d5a0cda73804897e9ea4fda4bee2e8c7";
    })
  ];

  preConfigure = ''
    sed -i 's,/usr/include,/no-such-dir,' configure
    sed -i "s!,'/usr/include/'!!" setup.py
  '';

  buildInputs = stdenv.lib.optional (!python.isPypy or false) gmp; # optional for pypy

  doCheck = !(python.isPypy or stdenv.isDarwin); # error: AF_UNIX path too long

  meta = {
    homepage = "http://www.pycrypto.org/";
    description = "Python Cryptography Toolkit";
    platforms = stdenv.lib.platforms.unix;
  };
}
