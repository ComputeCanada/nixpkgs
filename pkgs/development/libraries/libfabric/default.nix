{ stdenv, fetchurl, infinipath-psm, opa-psm2, libibverbs, librdmacm, libnl, ucx }:

stdenv.mkDerivation rec {
  name = "libfabric-1.5.2";

  src = fetchurl {
    url = "https://github.com/ofiwg/libfabric/releases/download/v1.5.2/${name}.tar.bz2";
    sha256 = "0v8dks6x0zw2hzdbpw38dccp5mz6fmhb1qdqhc31khcvj8g60py0";
  };

  patches = [ ./3249.patch ];

  buildInputs = [ infinipath-psm opa-psm2 libibverbs librdmacm libnl ucx ];

  configureFlags = [ "--with-libnl=${libnl.dev}" "--enable-psm=dl" "--enable-psm2=dl"
                     "--enable-verbs=dl" "--enable-mlx=dl" ];

  meta = with stdenv.lib; {
    homepage = https://ofiwg.github.io/libfabric/;
    license = with licenses; [ bsd2 gpl2 ];
    platforms = platforms.unix;
  };
}
