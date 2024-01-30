#!/bin/bash

set -o errexit

if [ ${EUID} != 0 ]; then
	echo "This setup script should only be run by root."
	exit 1
fi

cp -f /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup

pacman -Syy reflector

reflector --country 'United States' --latest 25 --age 24 --fastest 5 --protocol http,https --sort rate --save /etc/pacman.d/mirrorlist
