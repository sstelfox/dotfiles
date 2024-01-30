#!/bin/bash

set -o errexit

if [ ${EUID} != 0 ]; then
	echo "This setup script should only be run by root."
	exit 1
fi

pacman -Sy --needed --noconfirm pipewire pipewire-audio pipewire-pulse pipewire-v4l2 lib32-pipewire
