#!/bin/bash

set -o errexit

if [ ${EUID} != 0 ]; then
  echo "This setup script is expecting to run as root."
  exit 1
fi

wget -O /tmp/zoom.rpm https://zoom.us/client/latest/zoom_x86_64.rpm
dnf install /tmp/zoom.rpm -y
rm -f /tmp/zoom.rpm
