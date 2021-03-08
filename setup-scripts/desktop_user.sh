#!/bin/bash

set -o errexit

if [ ${EUID} = 0 ]; then
  echo "This setup script is expecting to run as a regular user."
  exit 1
fi

if [ "${DESKTOP_SESSION}" = "cinnamon" ]; then
  ~/.dotfiles/restore_cinnamon_settings.sh
  dconf write /org/cinnamon/prevent-focus-stealing true
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
