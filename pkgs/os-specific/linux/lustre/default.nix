{ stdenv, fetchurl, rpmextract }:

let
  version = "2.9.0";
in
  stdenv.mkDerivation {

    name = "lustre-${version}";

    src = fetchurl {
      url = "https://downloads.hpdd.intel.com/public/lustre/lustre-${version}/el7/client/SRPMS/lustre-${version}-1.src.rpm";
      sha256 = "958182977cfcb514fac4db4637040d2526f10b5c3eb8d59281b9b0ab13debe4f";
    };

    nativeBuildInputs = [ rpmextract ];

    unpackPhase = ''
      rpmextract $src
      tar -zxf lustre-${version}.tar.gz
      cd lustre-${version}
      sed -i s^rootsbindir=\'/sbin\'^rootsbindir=$out/sbin^ configure
      sed -i s^sysconfdir=\'/etc\'^sysconfdir=$out/etc^ configure 
    '';

    configureFlags = "--disable-modules";
    NIX_CFLAGS_COMPILE = "-Wno-error=deprecated-declarations";

    meta = {
      description = "Lustre file system clients and libraries";
    };
  }
