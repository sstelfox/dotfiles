#!/bin/bash

set -o errexit

if [ ${EUID} != 0 ]; then
  echo "This setup script is expecting to run as root."
  exit 1
fi

# A lot of my desktop specific software requires repos outside of the core, the
# RPM fusion repos handle that for me
if [ ! -f /etc/yum.repos.d/rpmfusion-free.repo ]; then
  dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm -y
fi

if [ ! -f /etc/yum.repos.d/rpmfusion-nonfree.repo ]; then
  dnf install https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y
fi

# fuse is required to run appimages like Obsidian
dnf install cheese discord fswebcam fuse libreoffice screen strace \
  transmission-gtk vlc xclip youtube-dl -y
