/* All git-relates tools live here, in a separate attribute set so that users
 * can get a fast overview over what's available.
 */
args @ {config, lib, pkgs}: with args; with pkgs;
let
  gitBase = callPackage ./git {
    svnSupport = false;         # for git-svn support
    guiSupport = false;         # requires tcl/tk
    sendEmailSupport = false;   # requires plenty of perl libraries
    perlLibs = [perlPackages.LWP perlPackages.URI perlPackages.TermReadKey];
    smtpPerlLibs = [
      perlPackages.libnet perlPackages.NetSMTPSSL
      perlPackages.IOSocketSSL perlPackages.NetSSLeay
      perlPackages.AuthenSASL perlPackages.DigestHMAC
    ];
  };

  self = rec {
  # Try to keep this generally alphabetized

  bfg-repo-cleaner = callPackage ./bfg-repo-cleaner { };

  darcsToGit = callPackage ./darcs-to-git { };

  diff-so-fancy = callPackage ./diff-so-fancy { };

  ghq = callPackage ./ghq { };

  git = appendToName "minimal" gitBase;

  git-appraise = callPackage ./git-appraise {};

  # The full-featured Git.
  gitFull = gitBase.override {
    svnSupport = true;
    guiSupport = true;
    sendEmailSupport = !stdenv.isDarwin;
    withLibsecret = !stdenv.isDarwin;
  };

  # Git with SVN support, but without GUI.
  gitSVN = lowPrio (appendToName "with-svn" (gitBase.override {
    svnSupport = true;
  }));

  git-annex = pkgs.haskellPackages.git-annex;

  git-annex-remote-b2 = callPackage ./git-annex-remote-b2 { };

  git-bug = callPackage ./git-bug { };

  # support for bugzilla
  git-bz = callPackage ./git-bz { };

  git-cola = callPackage ./git-cola { };

  git-crypt = callPackage ./git-crypt { };

  git-extras = callPackage ./git-extras { };

  git-hub = callPackage ./git-hub { };

  git-imerge = callPackage ./git-imerge { };

  git-octopus = callPackage ./git-octopus { };

  git-open = callPackage ./git-open { };

  git-radar = callPackage ./git-radar { };

  git-recent = callPackage ./git-recent {
    utillinux = if stdenv.isLinux then utillinuxMinimal else utillinux;
  };

  git-remote-hg = callPackage ./git-remote-hg { };

  git-secret = callPackage ./git-secret { };

  git-secrets = callPackage ./git-secrets { };

  git-stree = callPackage ./git-stree { };

  git-sync = callPackage ./git-sync { };

  git2cl = callPackage ./git2cl { };

  gitFastExport = callPackage ./fast-export { };

  gitRemoteGcrypt = callPackage ./git-remote-gcrypt { };

  gitflow = callPackage ./gitflow { };

  hub = callPackage ./hub {
    inherit (darwin) Security;
  };

  hubUnstable = throw "use gitAndTools.hub instead";

  pre-commit = callPackage ./pre-commit { };

  qgit = qt5.callPackage ./qgit { };

  stgit = callPackage ./stgit {
  };

  subgit = callPackage ./subgit { };

  svn2git = callPackage ./svn2git {
    git = gitSVN;
  };

  tig = callPackage ./tig { };

  topGit = callPackage ./topgit { };

  transcrypt = callPackage ./transcrypt { };

} // lib.optionalAttrs (config.allowAliases or true) (with self; {
  # aliases
  gitAnnex = git-annex;
});
in
  self
