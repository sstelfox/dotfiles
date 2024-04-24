#!/bin/bash

set -o errexit

if [ ${EUID} != 0 ]; then
	echo "This setup script should only be run by root."
	exit 1
fi

# https://community.frame.work/t/tracking-ppd-v-tlp-for-amd-ryzen-7040/39423/9
echo "WARNING! Apparently this shouldn't be done on the Framework laptop (debatable though)"

pacman -Sy --noconfirm ethtool tlp

systemctl stop systemd-rfkill.service systemd-rfkill.socket
systemctl mask systemd-rfkill.service systemd-rfkill.socket

systemctl enable tlp.service
systemctl start tlp.service
