#!/bin/bash

set -o errexit

if [ ${EUID} != 0 ]; then
  echo "This setup script is expecting to run as root."
  exit 1
fi

# A lot of my desktop specific software requires repos outside of the core, the
# RPM fusion repos handle that for me
dnf install \
  https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y

dnf install awscli cheese discord fswebcam gnupg2-smime libreoffice \
  pcsc-lite-ccid pinentry-gtk screen transmission-gtk vlc xclip youtube-dl -y

systemctl enable pcscd.service
systemctl start pcscd.service
