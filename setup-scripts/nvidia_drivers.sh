#!/bin/bash

set -o errexit

if [ ${EUID} != 0 ]; then
  echo "This setup script is expecting to run as root."
  exit 1
fi

sudo dnf install xorg-x11-drv-nvidia akmod-nvidia xorg-x11-drv-nvidia-cuda \
  vulkan xorg-x11-drv-nvidia-cuda-libs vdpauinfo libva-vdpau-driver \
  libva-utils -y
