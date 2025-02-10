#!/usr/bin/env false

# There isn't a POSIX compatible function for actually performing this, which can't be guaranteed to
# be present in my environments, and `type -P` isn't POSIX either.
posix_which() {
  binary="${1:-}"

  if [ -z "${binary}" ]; then
    echo "usage: posix_which BINARY" >&2
    return 1
  fi

  result=""

  saved_ifs="$IFS"
  IFS=:

  # Weird condition, but it came up so protect against it
  if [ -z "${PATH:-}" ]; then
    return 2
  fi

  # Read the PATH directly in the for loop with IFS set to :
  for dir in ${PATH}; do
    if [ -n "${dir}" ] && [ -x "${dir}/${binary}" ] && [ ! -d "${dir}/${binary}" ]; then
      result="${dir}/${binary}"
      break
    fi
  done

  IFS="${saved_ifs}"
  if [ -n "${result}" ]; then
    printf '%s\n' "${result}"
    return 0
  fi

  return 1
}
