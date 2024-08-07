#!/bin/bash

set -o errexit

if [ ${EUID} != 0 ]; then
  echo "This setup script should only be run by root."
  exit 1
fi

pacman -Sy --noconfirm --needed dnsmasq edk2-ovmf libvirt qemu-desktop swtpm virt-manager

systemctl enable libvirtd.service
