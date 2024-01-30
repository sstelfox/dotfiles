#!/bin/bash

set -o errexit

if [ ${EUID} != 0 ]; then
	echo "This setup script should only be run by root."
	exit 1
fi

pacman -Syy fuse2 wireguard-tools nftables podman tcpdump git-lfs graphviz iotop \
	git-crypt jq ripgrep blender inkscape gimp krita zopfli ansible discord \
	libreoffice-fresh screen strace vlc xclip transmission-qt yt-dlp clang \
	cmake nvidia-prime nvidia-utils rsync nvidia-dkms linux-hardened-headers \
	bluez bluez-utils fuse2 okular fd obsidian

# Secure boot setup
pacman -Syy sbctl

# For podman DNS networking
pacman -Syy aardvark-dns podman-dnsname

# This package seemed to massively improve the "lag" I felt on the work laptop
pacman -Syy xf86-video-amdgpu

# Some tools for interacting with my phone
pacman -Syy android-tools android-file-transfer android-udev

systemctl start bluetooth.service
systemctl enable bluetooth.service

# Used by neovim
pacman -Syy lazygit

# yay -S slack
# yay -S python-conda
