#!/bin/bash

set -o errexit

if [ ${EUID} != 0 ]; then
  echo "This setup script should only be run by root."
  exit 1
fi

# This is for steam
cat <<EOF >/etc/sysctl.d/00-enable-unprivileged-userns.conf
kernel.unprivileged_userns_clone=1
EOF
sysctl -w kernel.unprivileged_userns_clone=1
