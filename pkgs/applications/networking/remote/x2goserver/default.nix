{ stdenv, fetchurl, cups, libssh, libXpm, nxproxy, openldap, makeWrapper, qt4, man-old, which, perl, perlPackages }:

stdenv.mkDerivation rec {
  name = "x2goserver-${version}";
  version = "4.0.1.20";

  src = fetchurl {
    url = "http://code.x2go.org/releases/source/x2goserver/${name}.tar.gz";
    sha256 = "1nfslc08ynlqgdmjxf64wsxg4xyvdw01rpp6rnkxanwrr3hligzq";
  };

  buildInputs = [ cups libssh libXpm nxproxy openldap qt4 man-old which perl perlPackages.ConfigSimple perlPackages.DBI perlPackages.CaptureTiny perlPackages.DBDSQLite perlPackages.SysSyslog perlPackages.FileBaseDir perlPackages.FileWhich ];
  nativeBuildInputs = [ makeWrapper ];

  patchPhase = ''
     substituteInPlace Makefile \
       --replace "lrelease-qt4" "${qt4}/bin/lrelease" \
       --replace "qmake-qt4" "${qt4}/bin/qmake" \
       --replace "-o root -g root" "" \
       --replace '$(MAKE) -C x2goserver-printing $@' ""
     substituteInPlace x2goserver/Makefile \
       --replace "lrelease-qt4" "${qt4}/bin/lrelease" \
       --replace "qmake-qt4" "${qt4}/bin/qmake" \
       --replace "-o root -g root" "" \
       --replace '$(DESTDIR)/' '$(DESTDIR)/$(ETCDIR)/'
     substituteInPlace x2goserver-compat/Makefile \
       --replace "lrelease-qt4" "${qt4}/bin/lrelease" \
       --replace "qmake-qt4" "${qt4}/bin/qmake" \
       --replace "-o root -g root" ""
     substituteInPlace x2goserver-extensions/Makefile \
       --replace "lrelease-qt4" "${qt4}/bin/lrelease" \
       --replace "qmake-qt4" "${qt4}/bin/qmake" \
       --replace "-o root -g root" "" 
     substituteInPlace x2goserver-fmbindings/Makefile \
       --replace "lrelease-qt4" "${qt4}/bin/lrelease" \
       --replace "qmake-qt4" "${qt4}/bin/qmake" \
       --replace "-o root -g root" ""
     substituteInPlace x2goserver-pyhoca/Makefile \
       --replace "lrelease-qt4" "${qt4}/bin/lrelease" \
       --replace "qmake-qt4" "${qt4}/bin/qmake" \
       --replace "-o root -g root" ""
     substituteInPlace x2goserver-xsession/Makefile \
       --replace "lrelease-qt4" "${qt4}/bin/lrelease" \
       --replace "qmake-qt4" "${qt4}/bin/qmake" \
       --replace "-o root -g root" ""
  '';

  makeFlags = [ "build-arch" "build-indep" "PREFIX=$(out)" "ETCDIR=$(out)/etc" ];

  enableParallelBuilding = true;

#  installTargets = [ "install_server" ];
#  postInstall = ''
#    wrapProgram "$out/bin/x2goserver" --suffix PATH : "${nxproxy}/bin";
#  '';

#  installPhase = ''
#    patchShebangs . 
#  '';

  postInstall = ''
    patchShebangs $out
    for f in $(grep -l '\#\!/usr/bin/perl' $out/bin/* $out/sbin/* $out/lib/x2go/*); do
      substituteInPlace $f --replace /usr/bin/perl ${perl}/bin/perl
    done
    for f in $(grep -l '/etc/x2go/xtogosql' $out/bin/* $out/sbin/* $out/lib/x2go/*); do
      substituteInPlace $f --replace /etc/x2go/x2gosql $out/etc/x2gosql
    done
    substituteInPlace $out/sbin/x2godbadmin --replace 'user="x2gouser";' 'user=$ENV{USER};'
    substituteInPlace $out/lib/x2go/x2gosqlitewrapper.pl --replace "x2gouser='x2gouser';" 'x2gouser=$ENV{USER};'
  '';

  meta = with stdenv.lib; {
    description = "Graphical NoMachine NX3 remote desktop server";
    homepage = http://x2go.org/;
    license = licenses.gpl2;
    platforms = platforms.linux;
    maintainers = with maintainers; [ nckx ];
  };
}
