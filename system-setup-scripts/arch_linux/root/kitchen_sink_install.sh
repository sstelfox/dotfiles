#!/bin/bash

set -o errexit

if [ ${EUID} != 0 ]; then
  echo "This setup script should only be run by root."
  exit 1
fi

# Alacritty seems pretty good to me... Definitely an improvement over gnome terminal
pacman -Sy --needed --nocomfirm alacritty

pacman -Sy --needed --noconfirm wireguard-tools nftables podman tcpdump git-lfs graphviz iotop git-crypt \
  imagemagick jq ripgrep blender inkscape gimp krita zopfli libreoffice-fresh screen strace vlc xclip \
  transmission-qt yt-dlp clang cmake rsync fuse2 okular fd man-db gwenview

# Attempt at improving the default Linux spell checking facility as its rubbish by default
pacman -Sy --needed --noconfirm hunspell-en_us

#pacman -Sy --needed --noconfirm nvidia-prime nvidia-utils nvidia-dkms linux-hardened-headers

# Handy diff tool with syntax highlighting for git
pacman -Sy --needed --noconfirm git-delta

# Secure boot setup
pacman -Sy --needed --noconfirm sbctl

# Needed for podman to just run
pacman -Sy --needed --noconfirm fuse-overlayfs

# For podman DNS networking
#pacman -Sy --needed --noconfirm aardvark-dns podman-dnsname

# This package seemed to massively improve the "lag" I felt on the work laptop
#pacman -Sy --needed --noconfirm xf86-video-amdgpu

# Some tools for interacting with my phone
#pacman -Sy --needed --noconfirm android-tools android-file-transfer android-udev

# Used by neovim config
pacman -Sy --needed --noconfirm lazygit luarocks unzip
