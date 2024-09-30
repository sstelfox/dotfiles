#!/bin/bash

set -o errexit
set -o nounset

ROOT_MNT="/mnt/root"

if [ ${EUID} != 0 ]; then
  echo "This installation script must be as root from an Arch install medium"
  exit 1
fi

if [ "$(cat /etc/hostname)" != "archiso" ]; then
  echo "This installation script must be run from an Arch install medium"
  exit 2
fi

if ! mount 2>/dev/null | grep -q /mnt/root; then
  echo "Root filesystem does not appear to be mounted"
  exit 3
fi

#pacstrap -C /etc/pacman.conf -K /mnt/root plasma-meta konsole kwrite dolphin ark plasma-wayland-session egl-wayland --noconfirm

arch-chroot ${ROOT_MNT} pacman -Sy --needed --noconfirm mesa xf86-video-amdgpu libva-mesa-driver vulkan-radeon sddm plasma-meta kde-applications-meta networkmanager-qt powerdevil
arch-chroot ${ROOT_MNT} systemctl enable sddm.service
