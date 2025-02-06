#!/usr/bin/env false

is_privileged() {
  if [ "${EUID}" = 0 ]; then
    return 0
  fi

  return 1
}
