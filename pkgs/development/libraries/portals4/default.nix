{ stdenv, fetchurl, autoconf, automake, libtool, libev, libxml2, hwloc, knem }:

stdenv.mkDerivation rec {
  name = "portals4-1.0a1-2cc6c12";

  src = fetchurl {
    url = "https://github.com/Portals4/portals4/archive/2cc6c12ded7e64197e921bdd44cc5cfd92d811a9.tar.gz";
    sha256 = "c6e2f8ea77c1668c19107b351c0deff5393f83e264dcd6e5792a85bdd7e5cdad";
  };

  buildInputs = [ autoconf automake libtool libev libxml2 hwloc knem ];

  preConfigurePhases = ["./autogen.sh"];

  meta = with stdenv.lib; {
    homepage = http://www.cs.sandia.gov/Portals/portals4.html;
    license = licenses.bsd3;
    platforms = platforms.unix;
  };
}
