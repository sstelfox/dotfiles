#!/bin/bash

set -o errexit

if [ ${EUID} != 0 ]; then
	echo "This setup script is expecting to run as root."
	exit 1
fi

dnf install xorg-x11-drv-nvidia akmod-nvidia xorg-x11-drv-nvidia-cuda \
	vulkan xorg-x11-drv-nvidia-cuda-libs vdpauinfo libva-vdpau-driver \
	libva-utils -y

akmods --force || true
dracut --force || true

# TODO: need to sign and register using the self-signed certificate to get secure boot working again...
