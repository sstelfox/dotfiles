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

dnf install aircrack-ng awscli cheese fswebcam pcsc-lite-ccid pinentry-gtk \
  privoxy tor transmission-gtk vlc wireshark -y

systemctl enable pcscd.service
systemctl start pcscd.service

if [ "${DESKTOP_SESSION}" = "cinnamon" ]; then
  ~/.dotfiles/restore_cinnamon_settings.sh
fi

echo "I haven't yet automated this or know if I should, but if this machine has an"
echo "SSD installed as it's primary hard drive I should review /etc/fstab and add:"
echo
echo "\tdiscard,noatime,nodiratime"
echo
echo "to the appropriate partition mount options"
echo

# Things I still need to automate...
echo "Desktop checklist:"
echo "\t* Setup firefox user.js"
echo "\t* Install standard firefox extensions"
echo "\t* Switch default search engine to DuckDuckGo"

# Current list of firefox extensions: HTTPS Everywhere, Privacy Badger, Reddit
# Enhancement Suite, Snowflake, and uBlock Origin
