#!/usr/bin/env false

function is_privileged() {
  if [ "${EUID}" = 0 ]; then
    return 0
  fi

  return 1
}
