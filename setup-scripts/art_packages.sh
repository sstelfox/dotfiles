#!/bin/bash

set -o errexit

if [ ${EUID} != 0 ]; then
  echo "This setup script is expecting to run as root."
  exit 1
fi

dnf install blender gimp gimp-lqr-plugin gimp-save-for-web inkscape inkscape-psd inkscape-view -y
