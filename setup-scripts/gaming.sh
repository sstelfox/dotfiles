#!/bin/bash

set -o errexit

if [ ${EUID} != 0 ]; then
  echo "This setup script is expecting to run as root."
  exit 1
fi

dnf install discord lutris steam -y

# xdg-open lutris:magic-the-gathering-arena-latest-self-updating
# xdg-open lutris:magic-the-gathering-arena-dxvk-off
