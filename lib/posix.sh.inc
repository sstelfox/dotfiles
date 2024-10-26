#!/usr/bin/env false

if [ -z "${__DOTFILE_ROOT}" ]; then
  echo "POSIX library called without proper setup"
  exit 229
fi

__LIBRARY_PATH="${__DOTFILE_ROOT}/lib"

source "${__LIBRARY_PATH}/environment/access.sh.inc"
source "${__LIBRARY_PATH}/environment/git.sh.inc"
source "${__LIBRARY_PATH}/environment/operating_system.sh.inc"
source "${__LIBRARY_PATH}/environment/shell.sh.inc"
source "${__LIBRARY_PATH}/filesystem/utils.sh.inc"
