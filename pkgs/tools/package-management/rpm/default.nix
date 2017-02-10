{ stdenv, fetchurl, cpio, zlib, bzip2, file, elfutils, libarchive, nspr, nss, popt, db, xz, python, lua, pkgconfig, autoreconfHook, binutils }:

stdenv.mkDerivation rec {
  name = "rpm-4.13.0";

  src = fetchurl {
    url = "http://ftp.rpm.org/releases/rpm-4.13.x/rpm-4.13.0.tar.bz2";
    sha256 = "221166b61584721a8ca979d7d8576078a5dadaf09a44208f69cc1b353240ba1b";
  };

  buildInputs = [ cpio zlib bzip2 file libarchive nspr nss db xz python lua pkgconfig autoreconfHook binutils ];

  # rpm/rpmlib.h includes popt.h, and then the pkg-config file mentions these as linkage requirements
  propagatedBuildInputs = [ popt elfutils nss db bzip2 libarchive ];

  patches = [ ./bfdfix.patch ];

  NIX_CFLAGS_COMPILE = "-I${nspr.dev}/include/nspr -I${nss.dev}/include/nss";

  postPatch = ''
    # For Python3, the original expression evaluates as 'python3.4' but we want 'python3.4m' here
    substituteInPlace configure.ac --replace 'python''${PYTHON_VERSION}' ${python.executable}

    substituteInPlace Makefile.am --replace '@$(MKDIR_P) $(DESTDIR)$(localstatedir)/tmp' ""
  '';

  configureFlags = "--with-external-db --with-lua --enable-python --localstatedir=/var --sharedstatedir=/com";

  meta = with stdenv.lib; {
    homepage = http://www.rpm.org/;
    license = licenses.gpl2;
    description = "The RPM Package Manager";
    maintainers = with maintainers; [ mornfall copumpkin ];
    platforms = platforms.linux;
  };
}
