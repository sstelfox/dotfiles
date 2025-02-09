#!/usr/bin/env false

if [ ! -d "${HOME}/.tfenv" ]; then
  # affix colons on either side of $PATH to simplify matching
  case ":${PATH}:" in
    *:"${HOME}/.tfenv/bin":*)
      ;;
    *)
      # Prepending path in case a system-installed terraform needs to be overridden
      export PATH="${HOME}/.tfenv/bin:${PATH}"
      ;;
  esac
fi
