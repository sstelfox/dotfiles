#!/bin/bash

set -o errexit

if [ ${EUID} != 0 ]; then
  echo "This setup script should only be run by root."
  exit 1
fi

pacman -Sy --noconfirm opensnitch python-pyasn python-qt-material

systemctl enable --now opensnitchd.service
