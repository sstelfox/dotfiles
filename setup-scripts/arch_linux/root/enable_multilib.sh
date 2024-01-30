#!/bin/bash

set -o errexit

if [ ${EUID} != 0 ]; then
	echo "This setup script should only be run by root."
	exit 1
fi

if grep -q -E "^\[multilib\]$" /etc/pacman.conf; then
	echo 'Multilib already appears to be enabled, a full system upgrade may still be needed'
	exit 0
fi

pacman -Syyu

cat <<EOF >>/etc/pacman.conf

[multilib]
Include = /etc/pacman.d/mirrorlist
EOF

pacman -Syyu
