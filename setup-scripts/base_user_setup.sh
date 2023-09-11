#!/bin/bash

set -o errexit

if [ ${EUID} = 0 ]; then
	echo "This setup script is expecting to run as a regular user."
	exit 1
fi

#~/.dotfiles/install

gpg2 --import ~/.dotfiles/publickey.gpg
gpg2 --import-ownertrust ~/.dotfiles/trusted_keys.txt
