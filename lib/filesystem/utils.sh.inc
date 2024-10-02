#!/usr/bin/env false

function safe_symlink() {
  local src_path=$1
  local dst_path=$2

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
    return 1
  fi

  # Preflight passed, setup the link and return a positive response
  ln -s "${src_path}" "${dst_path}"

  return 0
}
