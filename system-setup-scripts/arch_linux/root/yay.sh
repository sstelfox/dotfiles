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

# Silent dependencies I may not have installed (such as my minimal server environments)
pacman --asdeps -S --needed --noconfirm debugedit fakeroot gcc make

# Direct dependencies of yay
pacman --asdeps -S --needed --noconfirm 'go>=1.19'

rm -rf /tmp/yay-build
mkdir /tmp/yay-build
chown nobody:nobody /tmp/yay-build

# Get a copy of the utility repo
setpriv --reuid=nobody --regid=nobody --init-groups /bin/bash -c '(
  cd /tmp/yay-build
  git clone https://aur.archlinux.org/yay.git

  cd /tmp/yay-build/yay
  export GOCACHE=$(pwd)/go-cache
  makepkg -c
)'

(
  cd /tmp/yay-build/yay
  pacman -U --noconfirm yay-*-x86_64.pkg.tar.zst
)

rm -rf /tmp/yay-build
