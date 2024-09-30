#!/bin/bash

set -o errexit

if [ ${EUID} != 0 ]; then
  echo "This setup script is expecting to run as root."
  exit 1
fi

dnf install aircrack-ng nmap privoxy tor wireshark -y

if [ -n "${SETUP_USER}" ]; then
  usermod -a -G wireshark ${SETUP_USER}
fi
