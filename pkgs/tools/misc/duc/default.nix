{ stdenv, fetchFromGitHub, autoreconfHook, pkgconfig, tokyocabinet, cairo, pango, ncurses, sqlite, pythonPackages }:

stdenv.mkDerivation rec {
  name = "duc-${version}";
  version = "1.4.4";

  src = fetchFromGitHub {
    owner = "zevv";
    repo = "duc";
    rev = "${version}";
    sha256 = "1i7ry25xzy027g6ysv6qlf09ax04q4vy0kikl8h0aq5jbxsl9q52";
  };

  buildInputs = [ autoreconfHook pkgconfig tokyocabinet cairo pango ncurses sqlite ]
                 ++ (with pythonPackages; [ sqlite3 ]);
  configureFlags = [ "--with-db-backend=sqlite3" ];

  meta = with stdenv.lib; {
    homepage = http://duc.zevv.nl/;
    description = "Collection of tools for inspecting and visualizing disk usage";
    license = licenses.gpl2;

    platforms = platforms.linux;
    maintainers = [ maintainers.lethalman ];
  };
}
