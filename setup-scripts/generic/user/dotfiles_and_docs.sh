#!/bin/bash

set -o errexit

if [ ${EUID} = 0 ]; then
	echo "This setup script is expecting to run as a regular user."
	exit 1
fi

if ! which git &>/dev/null; then
	echo 'Git must be installed before setup can begin'
	exit 1
fi

if [ ! -f ~/.dotfiles ]; then
	git clone https://github.com/sstelfox/dotfiles.git ~/.dotfiles
fi

~/.dotfiles/install

gpg2 --import ~/.dotfiles/publickey.gpg
gpg2 --import-ownertrust ~/.dotfiles/trusted_keys.txt

# note(sstelfox): restoring the secret key is as easy as copying the contents of a backed up
# version of the private-keys-v1.d into the newly created one. The past says hello!

if [ ! -d ~/documentation ]; then
	git clone hollow-twilight-ocean.stelfox.net:repos/documentation.git ~/documentation
fi
