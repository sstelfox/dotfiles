#!/bin/bash

set -o errexit

if [ ${EUID} != 0 ]; then
  echo "This setup script should only be run by root."
  exit 1
fi

pacman -Sy wireguard-tools nftables podman tcpdump git-lfs graphviz iotop \
  git-crypt jq ripgrep blender inkscape gimp krita zopfli ansible discord \
  libreoffice-fresh screen strace vlc xclip transmission-qt yt-dlp clang \
  cmake nvidia-prime nvidia-utils rsync nvidia-dkms linux-hardened-headers \
  bluez bluez-utils

systemctl start bluetooth.service
systemctl enable bluetooth.service
