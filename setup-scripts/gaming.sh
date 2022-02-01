#!/bin/bash

set -o errexit

if [ ${EUID} != 0 ]; then
  echo "This setup script is expecting to run as root."
  exit 1
fi

dnf install steam -y

# xdg-open lutris:magic-the-gathering-arena-latest-self-updating
# xdg-open lutris:magic-the-gathering-arena-dxvk-off

#dnf install lutris -y
# Lutris wants an absured number of file descriptors, elasticsearch also wants
# a bunch
#cat << EOF >> /etc/security/limits.conf
#*               soft    nofile          524288
#*               hard    nofile          524288
#EOF
