#!/bin/bash

set -o errexit

if [ ${EUID} != 0 ]; then
	echo "This setup script should only be run by root."
	exit 1
fi

# Useful for locating which packages contain a specific file (like a library or a binary)
pacman -Sy --noconfirm pkgfile
