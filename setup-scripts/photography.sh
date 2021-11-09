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
#
# cargo build --release
# ## -- mount sd card --
# ./target/release/dnglab convert /var/run/media/sstelfox/EOS_DIGITAL/DCIM/100CANON/ ~/Pictures/test_camera_roll/

if [ "${DESKTOP_ENABLED}" = "y" ]; then
  sudo dnf install darktable darktable-tools-noise -y
fi
