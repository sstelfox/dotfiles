#!/usr/bin/env false

function safe_symlink() {
  local src_path="${1:-}"
  local dst_path="${2:-}"

  if [ -z "${src_path}" ] || [ -z "${dst_path}" ]; then
    echo "usage: safe_symlink SYMLINK_SRC SYMLINK_DST"
    return 1
  fi

  # If it's already a link delete it to make sure we're pointing at the correct directory, if its a
  # link and pointing at an invalid location it will show up as if there is no file present but
  # will cause issues when creating a new one. We'll bypass the issue by accepting that we may
  # occasionally recreate a duplicate link.
  if [ -L "${dst_path}" ]; then
    rm "${dst_path}"
  fi

  # If it already exists we don't want to blindly override it, we'll simply return an error the
  # caller can act on
  if [ -f "${dst_path}" -o -d "${dst_path}" ]; then
    return 2
  fi

  # Make sure the destination parent directory exists
  if [ ! -d "$(dirname "${dst_path}")" ]; then
    mkdir -p "$(dirname "${dst_path}")"
  fi

  # Preflight passed, setup the link and return a positive response
  ln -s "${src_path}" "${dst_path}"

  return 0
}

# Before linking a config in place, checks if the provided program is present anywhere in the
# user's path. If so it performs the normal safe_symlink() option.
function safe_symlink_when_available() {
  local conditional_bin="${1:-}"
  local src_path="${2:-}"
  local dst_path="${3:-}"

  if [ -z "${conditional_bin}" ] || [ -z "${src_path}" ] || [ -z "${dst_path}" ]; then
    echo "usage: safe_symlink SYMLINK_SRC SYMLINK_DST"
    return 1
  fi

  if which "${conditional_bin}" >/dev/null 2>&1; then
    safe_symlink "${src_path}" "${dst_path}"
  fi
}
