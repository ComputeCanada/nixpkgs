{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  name = "knem-1.1.2";

  src = fetchurl {
    url = "http://gforge.inria.fr/frs/download.php/34521/${name}.tar.gz";
    sha256 = "4523ec59b15bd69db7956372d31e5cb8054627673a41154530310e9c4b8ea13e";
  };

  configurePhase = "true";

  buildPhase = "true";

  installPhase = "mkdir -p $out/include; install -m644 common/knem_io.h $out/include";

  meta = with stdenv.lib; {
    homepage = http://knem.gforge.inria.fr/;
    license = with licenses; [ bsd3 gpl2 ];
    platforms = platforms.unix;
  };
}
