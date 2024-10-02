#!/usr/bin/env false

function detect_shell() {
  local base_shell=$(basename "${SHELL:-}")

  case "${base_shell}" in
  bash)
    echo "bash"
    ;;
  zsh)
    echo "zsh"
    ;;
  *)
    # If we don't recognize what this is assume its the barest bones core shell experience like
    # you'd get from busybox. Should still be POSIX compliant but that's about all we can assume.
    echo "sh"
    ;;
  esac
}
