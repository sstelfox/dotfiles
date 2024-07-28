#!/bin/bash

set -o errexit

if [ ${EUID} != 0 ]; then
  echo "This setup script should only be run by root."
  exit 1
fi

pacman -Sy --noconfirm --needed qemu-guest-agent spice-vdagent xf86-video-qxl

# If the guest wants a graphical enviroment the following package would also be beneficial:
#
# * vulkan-virtio
