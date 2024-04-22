#!/bin/bash

set -o errexit

if [ ${EUID} != 0 ]; then
	echo "This setup script should only be run by root."
	exit 1
fi

pacman -Sy --noconfirm wireless-regdb

cat <<EOF >/etc/conf.d/wireless-regdom
WIRELESS_REGDOM="US"
EOF
