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

dnf install aircrack-ng ansible awscli cheese fswebcam libreoffice pcsc-lite-ccid \
  pinentry-gtk privoxy ShellCheck tor transmission-gtk vlc wireshark xclip youtube-dl -y

if [ -n "${SETUP_USER}" ]; then
  usermod -a -G wireshark ${SETUP_USER}
fi

systemctl enable pcscd.service
systemctl start pcscd.service

# Lutris wants an absured number of file descriptors, elasticsearch also needs a
# bunch
cat << EOF >> /etc/security/limits.conf
*               soft    nofile          524288
*               hard    nofile          524288
EOF
