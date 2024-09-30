#!/bin/bash

set -o errexit

if [ ${EUID} != 0 ]; then
	echo "This setup script should only be run by root."
	exit 1
fi

# A faster compatible linker for Rust
pacman -Sy --needed --noconfirm mold
