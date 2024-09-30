#!/bin/bash

set -o errexit

if [ ${EUID} != 0 ]; then
	echo "This setup script should only be run by root."
	exit 1
fi

pacman -Sy nvidia-dkms nvidia-prime nvidia-settings nvidia-utils nvtop

# AI/ML tools
pacman -Sy --needed --noconfirm cuda cudnn
