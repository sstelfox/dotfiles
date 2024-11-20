#!/usr/bin/env false

detect_shell() {
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

# Determines whether or not the environment the function is called in is a user's interactive shell
# or inside a script.
is_interactive_shell() {
  case $- in
    *i*) return 0 ;; # Interactive
    *) return 1 ;;   # Non-interactive
  esac
}
