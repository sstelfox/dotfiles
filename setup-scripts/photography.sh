#!/bin/bash

set -o errexit

if [ ${EUID} != 0 ]; then
  echo "This setup script is expecting to run as root."
  exit 1
fi

# I also need the following to handle CR3 raw files from my camera into
# something darktable can handle.
#
# * https://github.com/dnglab/dnglab.git

if [ "${DESKTOP_ENABLED}" = "y" ]; then
  sudo dnf install darktable darktable-tools-noise -y
fi
