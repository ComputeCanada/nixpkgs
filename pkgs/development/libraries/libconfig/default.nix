{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  name = "libconfig-${version}";
  version = "1.7";

  src = fetchurl {
    url = "https://hyperrealm.github.io/libconfig/dist/${name}.tar.gz";
    sha256 = "0h3zic85yjwm1vr77165rqdlv974m4jm8a9avzh88dw6yjxxr6yx";
  };

  meta = with stdenv.lib; {
    homepage = https://github.com/hyperrealm/libconfig;
    description = "A simple library for processing structured configuration files";
    license = licenses.lgpl3;
    maintainers = [ maintainers.goibhniu ];
    platforms = platforms.linux;
  };
}
