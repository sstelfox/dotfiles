#!/usr/bin/env false

# This non-descript file is where UV installs its environment setup. If it's present we want to
# source it to make UV available.
if [ -f "${HOME}/.local/bin/env" ]; then
  # shellcheck disable=SC1091 # when not present, shellcheck complains about this and I don't want
  # it to be checked anyway. It's beyond the control of this repo.
  . "${HOME}/.local/bin/env"
fi
