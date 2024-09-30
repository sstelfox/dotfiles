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

# Worth calling out when I first received the laptop it was running firmware
# version 3.0.3 and 3.0.5 was the latest version. fwupd (installer is
# ./firmware_updates.sh) should be able to handle this update. But I'm about to
# test that.
