{ stdenv, fetchurl, infinipath-psm, opa-psm2, rdma-core, libnl, ucx }:

stdenv.mkDerivation rec {
  name = "libfabric-1.6.1";

  src = fetchurl {
    url = "https://github.com/ofiwg/libfabric/releases/download/v1.6.1/${name}.tar.bz2";
    sha256 = "33215a91450e2234ebdc7c467f041b6757f76f5ba926425e89d80c27b3fd7da2";
  };

  buildInputs = [ infinipath-psm opa-psm2 rdma-core libnl ucx ];

  configureFlags = [ "--with-libnl=${libnl.dev}" "--enable-psm=dl" "--enable-psm2=dl"
                     "--enable-verbs=dl" "--enable-mlx=dl" ];

  meta = with stdenv.lib; {
    homepage = https://ofiwg.github.io/libfabric/;
    license = with licenses; [ bsd2 gpl2 ];
    platforms = platforms.unix;
  };
}
