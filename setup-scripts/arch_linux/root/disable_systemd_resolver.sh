#!/bin/bash

set -o errexit

if [ ${EUID} != 0 ]; then
	echo "This setup script should only be run by root."
	exit 1
fi

systemctl disable systemd-resolved.service
systemctl stop systemd-resolved.service
systemctl mask systemd-resovled.service
rm -f /etc/resolv.conf
systemctl restart NetworkManager.service
