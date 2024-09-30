#!/bin/bash

set -o errexit

if [ ${EUID} != 0 ]; then
  echo "This setup script is expecting to run as root."
  exit 1
fi

# zopfli is included for the `zopflipng` utility for image optimization
dnf install blender gimp gimp-lqr-plugin gimp-save-for-web inkscape inkscape-psd \
  inkscape-view krita zopfli -y
