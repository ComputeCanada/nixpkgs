hardeningFlags=(relro bindnow)
hardeningFlags+=("${hardeningEnable[@]}")
hardeningLDFlags=()
hardeningDisable=${hardeningDisable:-""}

hardeningDisable+=" @hardening_unsupported_flags@"

if [[ -n "$NIX_DEBUG" ]]; then echo HARDENING: Value of '$hardeningDisable': $hardeningDisable >&2; fi

if [[ ! $hardeningDisable =~ "all" ]]; then
  if [[ -n "$NIX_DEBUG" ]]; then echo 'HARDENING: Is active (not completely disabled with "all" flag)' >&2; fi
  for flag in "${hardeningFlags[@]}"
  do
    if [[ ! "${hardeningDisable}" =~ "$flag" ]]; then
      case $flag in
        relro)
          if [[ -n "$NIX_DEBUG" ]]; then echo HARDENING: enabling relro >&2; fi
          hardeningLDFlags+=('-z' 'relro')
          ;;
        bindnow)
          if [[ -n "$NIX_DEBUG" ]]; then echo HARDENING: enabling bindnow >&2; fi
          hardeningLDFlags+=('-z' 'now')
          ;;
        *)
          echo "Hardening flag unknown: $flag" >&2
          ;;
      esac
    fi
  done
fi
