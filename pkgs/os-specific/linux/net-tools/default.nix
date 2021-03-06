{ lib, stdenv, fetchurl,
  selinuxSupport? true, libselinux ? null, libsepol ? null,
}:

with lib;

stdenv.mkDerivation rec {
  name = "net-tools-1.60_p20120127084908";

  src = fetchurl {
    url = "mirror://gentoo/distfiles/${name}.tar.xz";
    sha256 = "408a51964aa142a4f45c4cffede2478abbd5630a7c7346ba0d3611059a2a3c94";
  };

  buildInputs = optionals selinuxSupport [ libselinux libsepol ];

  preBuild =
    ''
      cp ${./config.h} config.h
    '';

  makeFlags = "BASEDIR=$(out) mandir=/share/man HAVE_SELINUX=1";

  meta = {
    homepage = http://net-tools.sourceforge.net/;
    description = "A set of tools for controlling the network subsystem in Linux";
    license = stdenv.lib.licenses.gpl2Plus;
    platforms = stdenv.lib.platforms.linux;
  };
}
