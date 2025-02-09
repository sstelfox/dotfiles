#!/usr/bin/env false

# This script sets up the current shell to prefer my custom binaries and shell scripts over those
# present on the system. This does potentially allow an attacker with access to my dotfile sync, or
# user shell to MitM system binaries but also reduces the amount of programs needed to be installed
# in privileged locations. Currently I rely on git version tracking and difference reporting to
# detect unauthorized changes.
#
# TODO: Include some kind of notification in my terminal in my dotfiles or documentation has
# uncommitted changes.

if [ -n "${__DOTFILE_ROOT}" ]; then
  export PATH="${__DOTFILE_ROOT}/in_path/bin:${__DOTFILE_ROOT}/in_path/scripts:${PATH}"
else
  echo "warning: missing __DOTFILE_ROOT environment variable, unable to set bin & script path" >&2
fi
