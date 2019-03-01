{ stdenv, fetchurl, infinipath-psm, opa-psm2, rdma-core, libnl, ucx }:

stdenv.mkDerivation rec {
  name = "libfabric-1.7.0";

  src = fetchurl {
    url = "https://github.com/ofiwg/libfabric/releases/download/v1.7.0/${name}.tar.bz2";
    sha256 = "1i5arvpcg7y0qkimzhhn91q0ba9ir2g2gflpk4xqrzinzb09rpdk";
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
