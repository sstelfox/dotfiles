#!/usr/bin/env false

# This non-descript file is where UV installs its environment setup. If it's present we want to
# source it to make UV available.
if [ -f "${HOME}/.local/bin/env" ]; then
  . "${HOME}/.local/bin/env"
fi
