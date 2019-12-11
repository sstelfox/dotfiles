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

dnf install aircrack-ng awscli cheese fswebcam libreoffice pcsc-lite-ccid \
  pinentry-gtk privoxy tor transmission-gtk vlc wireshark xclip youtube-dl -y

systemctl enable pcscd.service
systemctl start pcscd.service

cat << EOF >> /etc/security/limits.conf
*               soft    nofile          65536
*               hard    nofile          65536
EOF
