{ stdenv, fetchurl, pkgconfig, curl, python, munge, perl, pam, openssl
, ncurses, mysql, gtk, lua, hwloc, numactl
}:

stdenv.mkDerivation rec {
  name = "slurm-llnl-${version}";
  version = "17-02-1-2";

  src = fetchurl {
    url = "https://github.com/SchedMD/slurm/archive/slurm-${version}.tar.gz";
    sha256 = "1nrh7v2l6s3yh0f9a44pfzfispiivd1flmjlxy6y1nh5r9gg85j9";
  };

  outputs = [ "bin" "out" "dev" "lib" ];

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [
    curl python munge perl pam openssl mysql.lib ncurses gtk lua hwloc numactl
  ];

  hardeningDisable = [ "bindnow" ];

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
    rm -f $lib/lib/*.la $lib/lib/slurm/*.la
  '';

  meta = with stdenv.lib; {
    homepage = http://www.schedmd.com/;
    description = "Simple Linux Utility for Resource Management";
    platforms = platforms.linux;
    license = licenses.gpl2;
    maintainers = [ maintainers.jagajaga ];
  };
}
