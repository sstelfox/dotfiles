#!/bin/bash

set -o errexit
set -o nounset

if [ ${EUID} != 0 ]; then
  echo "This setup script should only be run by root."
  exit 1
fi

source /etc/os-release

# Import the GPG key use for verifying the repo
rpm --import https://download.opensuse.org/repositories/network:/im:/signal/Fedora_${VERSION_ID}/repodata/repomd.xml.key

# OpenSUSE provides a Fedora build repository for this package which we can use
dnf config-manager --add-repo https://download.opensuse.org/repositories/network:im:signal/Fedora_${VERSION_ID}/network:im:signal.repo

dnf install signal-desktop -y
