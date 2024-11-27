#!/usr/bin/env false

if [ -z "${__DOTFILE_ROOT}" ]; then
  echo "POSIX library called without proper setup"
  exit 229
fi

__LIBRARY_PATH="${__DOTFILE_ROOT}/lib"
__DATA_PATH="${__DOTFILE_ROOT}/data"

source "${__LIBRARY_PATH}/logging.sh.inc"
source "${__LIBRARY_PATH}/trace.sh.inc"

# Enable our script tracing mechanism to help locate sources of issues when they occur
trace_init

source "${__LIBRARY_PATH}/environment/access.sh.inc"
source "${__LIBRARY_PATH}/environment/fonts.sh.inc"
source "${__LIBRARY_PATH}/environment/git.sh.inc"
source "${__LIBRARY_PATH}/environment/operating_system.sh.inc"
source "${__LIBRARY_PATH}/environment/shell.sh.inc"

source "${__LIBRARY_PATH}/filesystem/utils.sh.inc"

source "${__LIBRARY_PATH}/pkg/operating_system.sh.inc"
source "${__LIBRARY_PATH}/pkg/shell_installers.sh.inc"

source "${__LIBRARY_PATH}/security/multifactor.sh.inc"
source "${__LIBRARY_PATH}/services/k8s.sh.inc"
