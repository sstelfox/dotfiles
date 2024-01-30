#!/bin/bash

set -o errexit

if [ ${EUID} != 0 ]; then
	echo "This setup script should only be run by root."
	exit 1
fi

if ! which -q git &>/dev/null; then
	echo 'git is needed to install yay'
	exit 1
fi

pacman --asdeps -S --needed --noconfirm 'go>=1.19'

rm -rf /tmp/yay-build
mkdir /tmp/yay-build
chown nobody:nobody /tmp/yay-build

# Get a copy of the utility repo
su -s /bin/bash --pty nobody sh -c '(
  cd /tmp/yay-build
  git clone https://aur.archlinux.org/yay.git
)'

(
	cd /tmp/yay-build/yay
	export GOCACHE=$(pwd)/go-cache
	runuser -unobody -- makepkg -c
)

(
	cd /tmp/yay-build/yay
	pacman -U --noconfirm yay-*-x86_64.pkg.tar.zst
)

rm -rf /tmp/yay-build
