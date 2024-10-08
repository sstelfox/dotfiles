#!/usr/bin/env bash

__DOTFILE_ROOT="${__DOTFILE_ROOT:-${HOME}/.dotfiles}"

# Quick shim to call into my POSIX shell library for any supporting functions without loading the
# whole thing into ALL of my active shells (plc is short for POSIX lib call).
#
# This is using a special prefix of `,` which should be used for exposing any custom functionality
# or binaries I put into my PATH via dotfiles. This does not apply to public tooling I install (I
# don't rename other tools).
#
# The library functions do not follow this standard as they are intended to be accessed via this in
# shell environments that may have conflicts.
function ,plc() {
  local func_name="$1"
  shift

  (
    # We can be stricter about our shell usage within the calls, fail early & fast
    set -euo pipefail

    # Source my common shell library from my dotfiles
    . "${__DOTFILE_ROOT}/lib/posix.sh.inc"

    # Sanity check on the function call, if it isn't a function call or isn't defined we want to
    # produce a human friendly error rather than blindly calling it
    if declare -f "${func_name}" > /dev/null; then
      "${func_name}" "$@"

      # propagate the function's exit code to the caller
      return $?
    else
      echo "error: function '${func_name}' not found in the posix shell library" >&2
      return 230
    fi
  )

  # propagate the exit code from the subshell
  return $?
}
