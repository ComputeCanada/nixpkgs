{ stdenv, fetchgit, zlib, xz
, lz4 ? null
, lz4Support ? false
, zstd
}:

stdenv.mkDerivation rec {
  name = "squashfs-4.4";

  src = fetchgit {
    url = https://github.com/plougher/squashfs-tools.git;
    sha256 = "0697fv8n6739mcyn57jclzwwbbqwpvjdfkv1qh9s56lvyqnplwaw";
    # Tag "4.4" points to this commit.
    rev = "52eb4c279cd283ed9802dd1ceb686560b22ffb67";
  };

  buildInputs = [ zlib xz zstd ]
    ++ stdenv.lib.optional lz4Support lz4;

  preBuild = "cd squashfs-tools";

  installFlags = "INSTALL_DIR=\${out}/bin";

  makeFlags = [ "XZ_SUPPORT=1" "ZSTD_SUPPORT=1" ];

  meta = {
    homepage = http://squashfs.sourceforge.net/;
    description = "Tool for creating and unpacking squashfs filesystems";
    platforms = stdenv.lib.platforms.linux;
  };
}
