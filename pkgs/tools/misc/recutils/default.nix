{ fetchurl, stdenv, gettext, emacs, curl, check, bc }:

stdenv.mkDerivation rec {
  name = "recutils-1.5";

  src = fetchurl {
    url = "mirror://gnu/recutils/${name}.tar.gz";
    sha256 = "1v2xzwwwhc5j5kmvg4sv6baxjpsfqh8ln7ilv4mgb1408rs7xmky";
  };

  patches = [ ./glibc.patch ];

  doCheck = true;

  hardeningDisable = [ "format" ];

  buildInputs = [ curl emacs ] ++ (stdenv.lib.optionals doCheck [ check bc ]);

  meta = {
    description = "Tools and libraries to access human-editable, text-based databases";

    longDescription =
      '' GNU Recutils is a set of tools and libraries to access
         human-editable, text-based databases called recfiles.  The data is
         stored as a sequence of records, each record containing an arbitrary
         number of named fields.
      '';

    homepage = http://www.gnu.org/software/recutils/;

    license = stdenv.lib.licenses.gpl3Plus;

    platforms = stdenv.lib.platforms.all;
    maintainers = [ ];
  };
}
