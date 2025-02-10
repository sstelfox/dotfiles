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

 # Weird condition, but it came up so protect against it
 if [ -z "${PATH:-}" ]; then
   return 2
 fi

 # Create a clean copy of PATH with no leading/trailing colons
 clean_path="$(printf '%s' "${PATH}" | sed 's/^://;s/:$//')"

 saved_ifs="${IFS}"
 IFS=:

 # Use printf to ensure proper word splitting
 for dir in $(printf '%s\n' "${clean_path}"); do
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
