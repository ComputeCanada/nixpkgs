/* This file defines the composition for CPAN (Perl) packages.  It has
   been factored out of all-packages.nix because there are so many of
   them.  Also, because most Nix expressions for CPAN packages are
   trivial, most are actually defined here.  I.e. there's no function
   for each package in a separate file: the call to the function would
   be almost as must code as the function itself. */

{pkgs, overrides}:

let self = _self // overrides; _self = with self; {

  inherit (pkgs) buildPerlPackage fetchurl fetchFromGitHub stdenv perl fetchsvn gnused;

  inherit (stdenv.lib) maintainers;

  # Helper functions for packages that use Module::Build to build.
  buildPerlModule = { buildInputs ? [], ... } @ args:
    buildPerlPackage (args // {
      buildInputs = buildInputs ++ [ ModuleBuild ];
      preConfigure = "touch Makefile.PL";
      buildPhase = "perl Build.PL --prefix=$out; ./Build build";
      installPhase = "./Build install";
      checkPhase = "./Build test";
    });


  Perl4CoreLibs = buildPerlPackage {
    name = "Perl4-CoreLibs-0.003";
    src = fetchurl {
      url = "http://search.cpan.org/CPAN/authors/id/Z/ZE/ZEFRAM/Perl4-CoreLibs-0.003.tar.gz";
      sha256 = "55c9b2b032944406dbaa2fd97aa3692a1ebce558effc457b4e800dabfaad9ade";
    };
    meta = {
      description = "libraries historically supplied with Perl 4";
      homepage    = https://metacpan.org/pod/Perl4::CoreLibs/;
    };
  };


}; in self
