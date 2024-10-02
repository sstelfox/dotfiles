#!/usr/bin/env false

function detect_os() {
  if [ -n "${TERMUX_VERSION:-}" ]; then
    echo "termux"
    return 0
  fi

  # Fall back on the least common denominator, we know we're at least on a POSIX system by the
  # nature of us running
  echo "posix"
  return 0
}
