#!/bin/bash

set -o errexit

if [ ${EUID} != 0 ]; then
	echo "This setup script should only be run by root."
	exit 1
fi

# This handles the install but its setup is a bit fiddly (check the UEFI upgrade section):
#
# https://wiki.archlinux.org/title/Fwupd

pacman -Sy --noconfirm fwupd

# Normally this is started up automatically when queries are made to it, but I
# had issues with it starting out of the box. I think its missing a reference
# to libxmlb as its dependencies... Maybe should PR that...
systemctl start fwupd.service

fwupdmgr refresh
fwupdmgr get-updates
fwupdmgr update
