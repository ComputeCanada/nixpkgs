{ stdenv, fetchurl, infinipath-psm, opa-psm2, libibverbs, librdmacm, libnl, mxm }:

stdenv.mkDerivation rec {
  name = "libfabric-1.4.1";

  src = fetchurl {
    url = "https://github.com/ofiwg/libfabric/releases/download/v1.4.1/${name}.tar.bz2";
    sha256 = "fb165fe140a1c1828c49a4780860e669657221a2fc48f28b3934289b5da882a6";
  };

  buildInputs = [ infinipath-psm opa-psm2 libibverbs librdmacm libnl mxm ];

  configureFlags = [ "--with-libnl=${libnl.dev}" "--enable-psm=dl" "--enable-psm2=dl"
                     "--enable-mxm=dl" "--enable-verbs=dl" ];

  meta = with stdenv.lib; {
    homepage = https://ofiwg.github.io/libfabric/;
    license = with licenses; [ bsd2 gpl2 ];
    platforms = platforms.unix;
  };
}
