#!/bin/bash

set -o errexit

if [ ${EUID} != 0 ]; then
	echo "This setup script should only be run by root."
	exit 1
fi

pacman -Sy --noconfirm ethtool tlp

systemctl stop systemd-rfkill.service systemd-rfkill.socket
systemctl mask systemd-rfkill.service systemd-rfkill.socket

systemctl enable tlp.service
systemctl start tlp.service
