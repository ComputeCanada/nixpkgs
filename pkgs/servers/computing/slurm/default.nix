{ stdenv, fetchurl, pkgconfig, curl, python, munge, perl, pam, openssl
, ncurses, mysql, gtk, lua, hwloc, numactl
}:

stdenv.mkDerivation rec {
  name = "slurm-llnl-${version}";
  version = "16-05-9-1";

  src = fetchurl {
    url = "https://github.com/SchedMD/slurm/archive/slurm-${version}.tar.gz";
    sha256 = "fba18ca59b9e9d72f4e165c0e13fd65056002c578b1dae8862d64ee9a9f0a5ff";
  };

  outputs = [ "out" "dev" ];

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [
    curl python munge perl pam openssl mysql.lib ncurses gtk lua hwloc numactl
  ];

  configureFlags =
    [ "--with-munge=${munge}"
      "--with-ssl=${openssl.dev}"
      "--sysconfdir=/etc/slurm"
    ] ++ stdenv.lib.optional (gtk == null)  "--disable-gtktest";

  preConfigure = ''
    substituteInPlace ./doc/html/shtml2html.py --replace "/usr/bin/env python" "${python.interpreter}"
    substituteInPlace ./doc/man/man2html.py --replace "/usr/bin/env python" "${python.interpreter}"
  '';

  postInstall = ''
    rm -f $out/lib/*.la $out/lib/slurm/*.la
  '';

  meta = with stdenv.lib; {
    homepage = http://www.schedmd.com/;
    description = "Simple Linux Utility for Resource Management";
    platforms = platforms.linux;
    license = licenses.gpl2;
    maintainers = [ maintainers.jagajaga ];
  };
}
