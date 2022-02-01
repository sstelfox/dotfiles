#!/bin/bash

set -o errexit

if [ ${EUID} != 0 ]; then
  echo "This setup script is expecting to run as root."
  exit 1
fi

# https://keybase.io/docs/the_app/install_linux
dnf install https://prerelease.keybase.io/keybase_amd64.rpm -y
