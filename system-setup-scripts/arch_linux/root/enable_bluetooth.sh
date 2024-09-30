#!/bin/bash

set -o errexit

if [ ${EUID} != 0 ]; then
	echo "This setup script should only be run by root."
	exit 1
fi

#pacman -Sy --noconfirm bluez bluez-utils

systemctl enable bluetooth.service
systemctl start bluetooth.service
