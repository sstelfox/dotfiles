#!/bin/bash

set -o errexit

if [ ${EUID} != 0 ]; then
	echo "This setup script should only be run by root."
	exit 1
fi

pacman -Sy --needed --noconfirm signal-desktop

echo 'The signal tray hack fix is included in the user portion of these utilities'
