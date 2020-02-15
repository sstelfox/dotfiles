#!/bin/bash

set -o errexit

if [ ${EUID} != 0 ]; then
  echo "This setup script is expecting to run as root."
  exit 1
fi

dnf install libvirt swtpm swtpm-tools qemu-kvm virt-install -y

if [ "${DESKTOP_ENABLED}" = "y" ]; then
  dnf install virt-manager -y
fi

rm /etc/libvirt/qemu/networks/autostart/default.xml

systemctl enable libvirtd.service
