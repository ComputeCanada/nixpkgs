{ stdenv
, fetchFromGitHub
, cmake
, ispc
, tbb
, freeglut 
, libGL
, libGLU
, libpng 
, libXmu
, libXi
, imagemagick
}:


stdenv.mkDerivation rec {
    name = "embree-${version}";
    version = "2.15.0";

    src = fetchFromGitHub {
        owner = "embree";
        repo = "embree";
        rev = "f8b4b464d6d0380cf45b64ae78d9e1c9d9a9beab";
        sha256 = "1nykv2bliaha00fpis26ar0llda84k9xqbysp53q0a2fav38y1y7";
    };
    

    buildInputs = [ cmake ispc tbb freeglut 
                    libGL libGLU libpng libXmu libXi imagemagick ];

    cmakeFlags = [ "-DOPENGL_gl_LIBRARY=${libGL}/lib/libGL.so" ];

    postInstall = "substituteInPlace $out/lib/cmake/embree-2.15.0/embree-config.cmake --replace $out/ ''";

}


