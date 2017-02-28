if [ -e @out@/nix-support/libc-ldflags ]; then
    export NIX_LDFLAGS+=" $(eval echo $(cat @out@/nix-support/libc-ldflags))"
fi

if [ -e @out@/nix-support/libc-ldflags-before ]; then
    export NIX_LDFLAGS_BEFORE="$(eval echo $(cat @out@/nix-support/libc-ldflags-before)) $NIX_LDFLAGS_BEFORE"
fi

export NIX_CC_WRAPPER_FLAGS_SET=1
