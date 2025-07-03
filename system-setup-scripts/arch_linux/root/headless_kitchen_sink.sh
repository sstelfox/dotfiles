#!/bin/bash

set -o errexit

if [ ${EUID} != 0 ]; then
  echo "This setup script should only be run by root."
  exit 1
fi

pacman -Sy --needed --noconfirm dnsutils iotop zopfli strace clang rsync fuse2 patch
