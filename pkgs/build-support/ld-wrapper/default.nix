# The Nixpkgs LD is not directly usable, since it doesn't know where
# the C library is. Therefore the linker produced by that package
# cannot be installed directly in a user environment and used from
# the command line. So we use a wrapper script that sets up the
# right environment variables so that the linker just "works".

{ name ? "", stdenv
, libc ? null, binutils ? null, coreutils ? null, shell ? stdenv.shell
}:

with stdenv.lib;

let

  binutilsVersion = (builtins.parseDrvName binutils.name).version;
  binutilsName = (builtins.parseDrvName binutils.name).name;

  libc_bin = getBin libc;
  libc_dev = getDev libc;
  libc_lib = getLib libc;
  binutils_bin = getBin binutils;
  # The wrapper scripts uses 'cat', so we may need coreutils.
  coreutils_bin = getBin coreutils;
in

stdenv.mkDerivation {
  name =
    (if name != "" then name else binutilsName + "-wrapper") +
    (if binutils != null && binutilsVersion != "" then "-" + binutilsVersion else "");

  preferLocalBuild = true;

  inherit shell libc_bin libc_dev libc_lib binutils_bin coreutils_bin;

  passthru = {
    inherit libc;

    emacsBufferSetup = pkgs: ''
      ; We should handle propagation here too
      (mapc (lambda (arg)
        (when (file-directory-p (concat arg "/lib"))
          (setenv "NIX_LDFLAGS" (concat (getenv "NIX_LDFLAGS") " -L" arg "/lib")))
        (when (file-directory-p (concat arg "/lib64"))
          (setenv "NIX_LDFLAGS" (concat (getenv "NIX_LDFLAGS") " -L" arg "/lib64")))) '(${concatStringsSep " " (map (pkg: "\"${pkg}\"") pkgs)}))
    '';
  };

  buildCommand =
    ''
      mkdir -p $out/bin $out/nix-support $out/etc

      echo "/cvmfs/soft.computecanada.ca/nix/var/nix/profiles/16.09/lib" > $out/etc/ld.so.conf
      echo "/usr/lib64/nvidia" >> $out/etc/ld.so.conf

      wrap() {
        local dst="$1"
        local wrapper="$2"
        export prog="$3"
        substituteAll "$wrapper" "$out/bin/$dst"
        chmod +x "$out/bin/$dst"
      }

      dynamicLinker="\$NIXUSER_PROFILE/lib/$dynamicLinker"
      echo $dynamicLinker > $out/nix-support/dynamic-linker

      # explicit overrides of the dynamic linker by callers to gcc/ld
      # (the *last* value counts, so ours should come first).
      echo "-dynamic-linker" $dynamicLinker > $out/nix-support/libc-ldflags-before

      ldPath="${binutils_bin}/bin"

      # Propagate the wrapped cc so that if you install the wrapper,
      # you get binutils, the manpages, etc. as well
      echo ${binutils_bin} > $out/nix-support/propagated-user-env-packages

      wrap ld ${./ld-wrapper.sh} ''${ld:-$ldPath/ld}

      if [ -e ${binutils_bin}/bin/ld.gold ]; then
        wrap ld.gold ${./ld-wrapper.sh} ${binutils_bin}/bin/ld.gold
      fi

      if [ -e ${binutils_bin}/bin/ld.bfd ]; then
        wrap ld.bfd ${./ld-wrapper.sh} ${binutils_bin}/bin/ld.bfd
      fi

      substituteAll ${./setup-hook.sh} $out/nix-support/setup-hook.tmp
      cat $out/nix-support/setup-hook.tmp >> $out/nix-support/setup-hook
      rm $out/nix-support/setup-hook.tmp

      # some linkers on some platforms don't support specific -z flags
      hardening_unsupported_flags=""
      if [[ "$($ldPath/ld -z now 2>&1 || true)" =~ "unknown option" ]]; then
        hardening_unsupported_flags+=" bindnow"
      fi
      if [[ "$($ldPath/ld -z relro 2>&1 || true)" =~ "unknown option" ]]; then
        hardening_unsupported_flags+=" relro"
      fi

      substituteAll ${./add-flags.sh} $out/nix-support/add-flags.sh
      substituteAll ${./add-hardening.sh} $out/nix-support/add-hardening.sh
    '';

  # The dynamic linker has different names on different Linux platforms.
  dynamicLinker = "ld-linux-x86-64.so.2";

  meta =
    { description =
        stdenv.lib.attrByPath ["meta" "description"] "System linker ld (wrapper script)";
    };
}
