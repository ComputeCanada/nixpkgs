{ stdenv, requireFile, libuuid, numactl, cudatoolkit }:

stdenv.mkDerivation rec {
  name = "opa-psm2-11.2.80";

  src = requireFile {
    name = "libpsm2-11.2.80.tar.gz";
    url = "file:///localhost";
    sha256 = "b895eff9a6c8c03651b28c6817ca6aa5236a57f3c4599f7c868aeb393b0c4654";
  };

  configurePhase = "sed -i 's|/usr|/|' Makefile";

  patches = [ ./opa-psm2-hfi-user.patch ];

  hardeningDisable = [ "format" ];

  buildInputs = [ libuuid numactl cudatoolkit ];
  buildPhase = "make arch=x86_64 USE_PSM_UUID=1 PSM_CUDA=1";

  installPhase = "make install arch=x86_64 DESTDIR=$out";

  meta = with stdenv.lib; {
    homepage = https://www.openfabrics.org/;
    license = licenses.bsd2;
    platforms = platforms.unix;
  };
}
