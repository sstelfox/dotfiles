#!/bin/bash

set -o errexit

if [ ${EUID} != 0 ]; then
  echo "This setup script should only be run by root."
  exit 1
fi

pacman -Sy --needed --noconfirm wireguard-tools nftables tcpdump graphviz iotop \
  imagemagick blender inkscape gimp krita zopfli libreoffice-fresh screen strace vlc xclip \
  transmission-qt yt-dlp clang cmake rsync fuse2 okular man-db gwenview

# Attempt at improving the default Linux spell checking facility as its rubbish by default
pacman -Sy --needed --noconfirm hunspell-en_us

#pacman -Sy --needed --noconfirm nvidia-prime nvidia-utils nvidia-dkms linux-hardened-headers

# Secure boot setup
pacman -Sy --needed --noconfirm sbctl

# This package seemed to massively improve the "lag" I felt on the work laptop
#pacman -Sy --needed --noconfirm xf86-video-amdgpu

# Some tools for interacting with my phone
#pacman -Sy --needed --noconfirm android-tools android-file-transfer android-udev
