#!/bin/bash

set -o errexit

if [ ${EUID} != 0 ]; then
	echo "This setup script should only be run by root."
	exit 1
fi

if ! grep -q -E "^\[multilib\]$" /etc/pacman.conf; then
	echo 'Multilib must be enabled before steam can be installed'
	exit 0
fi

pacman -Syy steam lib32-nvidia-utils lib32-amdvlk
