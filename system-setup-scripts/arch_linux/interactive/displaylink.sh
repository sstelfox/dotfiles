#!/bin/bash

set -o errexit

if [ ${EUID} = 0 ]; then
	echo "This setup script is expecting to run as a regular user with sudo permissions"
	exit 1
fi

if ! which yay &>/dev/null; then
	echo 'yay needs to be installed to install this AUR package'
	exit 1
fi

sudo pacman -Sy --needed --noconfirm linux-hardened-headers

yay -S evdi-git
yay -S displaylink

sudo systemctl enable displaylink.service

cat <<EOF | sudo tee /etc/X11/xorg.conf.d/20-evdi.conf
Section "OutputClass"
	Identifier "DisplayLink"
	MatchDriver "evdi"
	Driver "modesetting"
	Option "AccelMethod" "none"
EndSection
EOF
