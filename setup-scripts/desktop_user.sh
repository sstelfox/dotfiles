#!/bin/bash

set -o errexit

if [ ${EUID} = 0 ]; then
  echo "This setup script is expecting to run as a regular user."
  exit 1
fi

if [ "${DESKTOP_SESSION}" = "cinnamon" ]; then
  ~/.dotfiles/scripts/restore_desktop_settings.sh
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

# Current list of firefox extensions:
#
#   - ClearURLs
#   - Decentraleyes
#   - HTTPS Everywhere
#   - Privacy Badger
#   - Privacy Possum
#   - Reddit Enhancement Suite
#   - Snowflake (on desktops)
#   - uBlock Origin
#
# Potential additions:
#
#   - AdNauseam
