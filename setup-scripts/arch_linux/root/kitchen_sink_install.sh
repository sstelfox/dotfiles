#!/bin/bash

set -o errexit

if [ ${EUID} != 0 ]; then
	echo "This setup script should only be run by root."
	exit 1
fi

pacman -Sy --noconfirm wireguard-tools nftables podman tcpdump git-lfs graphviz iotop git-crypt \
	jq ripgrep blender inkscape gimp krita zopfli libreoffice-fresh screen strace vlc xclip \
	transmission-qt yt-dlp clang cmake rsync fuse2 okular fd man-db

#pacman -Sy --noconfirm nvidia-prime nvidia-utils nvidia-dkms linux-hardened-headers

# Secure boot setup
pacman -Sy --noconfirm sbctl

# For podman DNS networking
pacman -Sy --noconfirm aardvark-dns podman-dnsname

# This package seemed to massively improve the "lag" I felt on the work laptop
#pacman -Syy xf86-video-amdgpu

# Some tools for interacting with my phone
#pacman -Syy android-tools android-file-transfer android-udev

# Used by neovim
pacman -Sy --noconfirm lazygit
