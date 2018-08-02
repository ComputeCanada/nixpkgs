#! @shell@ -e

expandResponseParams() {
    local inparams=("$@")
    local n=0
    local p
    params=()
    while [ $n -lt ${#inparams[*]} ]; do
        p=${inparams[n]}
        case $p in
            @*)
                if [ -e "${p:1}" ]; then
                    args=$(<"${p:1}")
                    eval 'for arg in '${args//$/\\$}'; do params+=("$arg"); done'
                else
                    params+=("$p")
                fi
                ;;
            *)
                params+=("$p")
                ;;
        esac
        n=$((n + 1))
    done
}

if [ -z "$NIXUSER_PROFILE" ]; then
  NIXUSER_PROFILE=/cvmfs/soft.computecanada.ca/nix/var/nix/profiles/16.09
fi
if [ -z "$EASYBUILD_CONFIGFILES" ]; then
  EASYBUILD_CONFIGFILES=/cvmfs/soft.computecanada.ca/easybuild/config.cfg
fi

path_backup="$PATH"
if [ -n "@coreutils_bin@" ]; then
  PATH="@coreutils_bin@/bin"
fi

if [ -n "$NIX_LD_WRAPPER_START_HOOK" ]; then
    source "$NIX_LD_WRAPPER_START_HOOK"
fi

if [ -z "$NIX_CC_WRAPPER_FLAGS_SET" ]; then
    source @out@/nix-support/add-flags.sh
fi

# Filter out rpaths that refer to the store.
expandResponseParams "$@"
if [ "$NIX_DONT_SET_RPATH" != 1 -a -n "$NIXUSER_PROFILE" -a -n "$EASYBUILD_CONFIGFILES" ]; then
    NIX_STORE=${NIXUSER_PROFILE%/var/nix/profiles/*}/store
    rest=()
    n=0
    while [ $n -lt ${#params[*]} ]; do
        p=${params[n]}
        p2=${params[$((n+1))]}
        if [ "$p" = -rpath ] && [ "${p2:0:${#NIX_STORE}}" == "$NIX_STORE" ]; then
            n=$((n + 1))
        else
            rest=("${rest[@]}" "$p")
        fi
        n=$((n + 1))
    done
    params=("${rest[@]}")
fi

LD=@prog@
source @out@/nix-support/add-hardening.sh

extra=(${hardeningLDFlags[@]})
extraBefore=()

if [ -z "$NIX_LDFLAGS_SET" ]; then
    extra+=($NIX_LDFLAGS)
    extraBefore+=($NIX_LDFLAGS_BEFORE)
fi

extra+=($NIX_LDFLAGS_AFTER)
extraBefore+=($NIX_LDFLAGS_HARDEN)

# This hook instructs the Nix LD wrapper to only keep rpaths into
# the EasyBuild software repository and Nix profiles,
# instead of Nix store rpaths.

if [ "$NIX_DONT_SET_RPATH" != 1 -a -n "$NIXUSER_PROFILE" -a -n "$EASYBUILD_CONFIGFILES" ]; then
    NIX_STORE=${NIXUSER_PROFILE%/var/nix/profiles/*}/store
    NIX_PROFILE_DIR=${NIXUSER_PROFILE%/*}
    EASYBUILD_DIR=${EASYBUILD_CONFIGFILES%/*}

    libPath=""
    addToLibPath() {
        local path="$1"
        if [ "${path:0:1}" != / ]; then return 0; fi
        case "$path" in
            *..*|*./*|*/.*|*//*)
                local path2
                if path2=$(readlink -f "$path"); then
                    path="$path2"
                fi
                ;;
        esac
        case $libPath in
            *\ $path\ *) return 0 ;;
        esac
        libPath="$libPath $path "
    }

    addToRPath() {
        # Only NIX_PROFILE_DIR and EASYBUILD library paths are added
        # to rpath. No /tmp, /dev/shm, etc.
        if [ "${1:0:${#NIX_PROFILE_DIR}}" != "$NIX_PROFILE_DIR" -a \
            "${1:0:${#EASYBUILD_DIR}}" != "$EASYBUILD_DIR" ]; then
            return 0
        fi
        # this gets explicitly added at the end only using -rpath-link
        if [ "$1" == "$NIXUSER_PROFILE/lib" -a -z "$2" ]; then
            return 0
        fi
        if [ "$1" == "$NIXUSER_PROFILE/lib64" ]; then
            return 0
        fi
        case $rpath in
            *\ $1\ *) return 0 ;;
        esac
        rpath="$rpath $1 "
    }

    libs=""
    addToLibs() {
        libs="$libs $1"
    }

    rpath='$ORIGIN/../lib $ORIGIN/../lib64'

    # First, find all -L... switches.
    allParams=("${params[@]}" ${extra[@]})
    n=0
    static=0
    while [ $n -lt ${#allParams[*]} ]; do
        p=${allParams[n]}
        p2=${allParams[$((n+1))]}
        if [ "${p:0:3}" = -L/ ]; then
            addToLibPath ${p:2}
        elif [ "$p" = -L ]; then
            addToLibPath ${p2}
            n=$((n + 1))
        elif [ "$p" = -l -a $static = 0 ]; then
            addToLibs ${p2}
            n=$((n + 1))
        elif [ "${p:0:2}" = -l -a $static = 0 ]; then
            addToLibs ${p:2}
        elif [ "$p" = -Bstatic ]; then
	    static=1
        elif [ "$p" = -Bdynamic ]; then
	    static=0
        elif [ "$p" = -dynamic-linker ]; then
            if [ "${p2:0:${#NIX_STORE}}" == "$NIX_STORE" ]; then
	        params[$((n+1))]=$NIXUSER_PROFILE/lib/${p2##*/}
	    fi
            # Ignore the dynamic linker argument, or it
            # will get into the next 'elif'. We don't want
            # the dynamic linker path rpath to go always first.
            n=$((n + 1))
        elif [[ "$p" =~ ^[^-].*\.so($|\.) ]]; then
            # This is a direct reference to a shared library, so add
            # its directory to the rpath.
            path="$(dirname "$p")";
            addToRPath "${path}"
        else
	    for suffix in 1 i n; do
		if [ "$p" = crt$suffix.o -a ! -f "$p" ]; then
		    params[$n]=$NIXUSER_PROFILE/lib/$p
		elif [ "$p" = /usr/lib64/crt$suffix.o ]; then
		    params[$n]=$NIXUSER_PROFILE/lib/crt$suffix.o
		fi
	    done
        fi
        n=$((n + 1))
    done

    # Second, for each directory in the library search path (-L...),
    # see if it contains a dynamic library used by a -l... flag.  If
    # so, add the directory to the rpath.
    # It's important to add the rpath in the order of -L..., so
    # the link time chosen objects will be those of runtime linking.

    unset FOUNDLIBS
    declare -A FOUNDLIBS
    for i in $libPath; do
        if [ "${i:0:${#NIX_PROFILE_DIR}}" == "$NIX_PROFILE_DIR" -o \
             "${i:0:${#EASYBUILD_DIR}}" == "$EASYBUILD_DIR" ]; then
            for j in $libs; do
    	        foundlib=${FOUNDLIBS["$j"]}
                if [ -z "$foundlib" -a -f "$i/lib$j.so" ]; then
                    addToRPath $i
		    break
                fi
            done
            for j in $libs; do
	        foundlib=${FOUNDLIBS["$j"]}
                if [ -z "$foundlib" -a -f "$i/lib$j.so" ]; then
		    FOUNDLIBS["$j"]=1
                fi
            done
	fi
    done


    # Finally, add `-rpath' switches.
    for i in $rpath; do
        extra+=(-rpath $i)
    done
    case $rpath in
        *\ $NIXUSER_PROFILE/lib\ *) ;;
        *) extra+=(-rpath-link $NIXUSER_PROFILE/lib) ;;
    esac
fi

# Optionally print debug info.
if [ -n "$NIX_DEBUG" ]; then
  echo "original flags to @prog@:" >&2
  for i in "${params[@]}"; do
      echo "  $i" >&2
  done
  echo "extra flags to @prog@:" >&2
  for i in ${extra[@]}; do
      echo "  $i" >&2
  done
fi

if [ -n "$NIX_LD_WRAPPER_EXEC_HOOK" ]; then
    source "$NIX_LD_WRAPPER_EXEC_HOOK"
fi

PATH="$path_backup"
exec @prog@ ${extraBefore[@]} "${params[@]}" ${extra[@]}
