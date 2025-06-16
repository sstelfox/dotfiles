#!/usr/bin/env false

# Hostname is surprisingly hard to consistently get across platforms
full_hostname() {
  if command -v hostname >/dev/null 2>&1; then
    hostname
  elif [ -f /etc/hostname ]; then
    cat /etc/hostname
  elif [ -f /proc/sys/kernel/hostname ]; then
    cat /proc/sys/kernel/hostname
  elif command -v uname >/dev/null 2>&1; then
    uname -n
  else
    echo "could not determine hostname" >&2
    exit 1
  fi
}
