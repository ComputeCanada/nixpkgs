{ stdenv, fetchurl, vim, bison, db }:

stdenv.mkDerivation rec {
  name = "ksh-${version}";
  version = "2012-08-01-683bccf";

  src = fetchurl {
    urls = [
      "https://github.com/att/ast/archive/683bccf.tar.gz"
    ];
    sha256 = "c0f05d779cd9efeb62b00f02f04505d04a6a0b57c0b1bd87dce1e3fa10ab753f";
  };

  patches = [ ./ardir-perms.patch ];

  buildInputs = [ vim bison db ];

  hardeningDisable = [ ];

  buildPhase = ''
    CCFLAGS="-O2 -fno-strict-aliasing" bin/package make
  '';

  installPhase = ''
    mkdir -p $out/bin $out/share/man/man1
    install -D -m 755 arch/*/bin/ksh $out/bin/ksh93
    install -D -m 755 arch/*/bin/shcomp $out/bin
    ln -s ksh93 $out/bin/rksh
    ln -s ksh93 $out/bin/ksh
    install -D -m 644 arch/*/man/man1/sh.1 $out/share/man/man1/ksh93.1
    ln -s ksh93.1 $out/share/man/man1/ksh.1
  '';

  meta = with stdenv.lib; {
    description = "Korn Shell";
    longDescription = ''
      The KornShell language was designed and developed by David G. Korn
      at AT&T Bell Laboratories. It is an interactive command language that
      provides access to the UNIX system and to many other systems, on the many
      different computers and workstations on which it is implemented.
    '';
    homepage = "http://kornshell.com";
    license = licenses.epl10;
    maintainers = with maintainers; [ bartoldeman ];
    platforms = platforms.unix;
  };

  passthru = {
    shellPath = "/bin/ksh";
  };
}
