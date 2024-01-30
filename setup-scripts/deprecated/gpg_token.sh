#!/bin/bash

set -o errexit

if [ ${EUID} != 0 ]; then
  echo "This setup script is expecting to run as root."
  exit 1
fi

dnf install gnupg2-smime pcsc-lite-ccid pinentry-gtk -y

systemctl enable pcscd.service
systemctl start pcscd.service
