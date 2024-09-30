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

yay -S --norebuild --cleanafter slack-desktop
