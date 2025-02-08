#!/usr/bin/env false

if [ -z "${__DOTFILE_ROOT}" ]; then
  echo "POSIX library called without proper setup"
  exit 229
fi

__LIBRARY_PATH="${__DOTFILE_ROOT}/lib"
__DATA_PATH="${__DOTFILE_ROOT}/data"

# shellcheck source-path=./lib

. "${__LIBRARY_PATH}/logging.sh.inc"
. "${__LIBRARY_PATH}/trace.sh.inc"

# Enable our script tracing mechanism to help locate .s of issues when they occur
trace_init

. "${__LIBRARY_PATH}/environment/access.sh.inc"
. "${__LIBRARY_PATH}/environment/fonts.sh.inc"
. "${__LIBRARY_PATH}/environment/git.sh.inc"
. "${__LIBRARY_PATH}/environment/operating_system.sh.inc"
. "${__LIBRARY_PATH}/environment/shell.sh.inc"

. "${__LIBRARY_PATH}/filesystem/utils.sh.inc"

. "${__LIBRARY_PATH}/pkg/operating_system.sh.inc"
. "${__LIBRARY_PATH}/pkg/shell_installers.sh.inc"

. "${__LIBRARY_PATH}/security/multifactor.sh.inc"

. "${__LIBRARY_PATH}/services/k8s.sh.inc"
. "${__LIBRARY_PATH}/services/ssh.sh.inc"
