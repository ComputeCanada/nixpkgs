{ stdenv, requireFile, python27, asciidoc, libxml2, libxslt, docbook_xml_dtd_45, docbook_xml_xslt, strace }:

stdenv.mkDerivation rec {
  name = "libscif-3.8.1";

  src = requireFile {
    name = "${name}.tar.bz2";
    url = "file:///localhost";
    sha256 = "fad84430013ad9fa8b48186abed0ee1e720023a4b74f963bb7a0e07cbf13dec8";
  };

  buildInputs = [ python27 asciidoc libxml2 libxslt docbook_xml_dtd_45 docbook_xml_xslt strace ];

  installFlags = [ "prefix=$(out)" ];

  patches = [ ./libscif-metadata.patch ];

  meta = with stdenv.lib; {
    homepage = https://software.intel.com/en-us/articles/intel-manycore-platform-software-stack-mpss/;
    license = licenses.lgpl21;
    platforms = platforms.unix;
  };
}
