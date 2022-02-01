#!/bin/bash

set -o errexit

if [ ${EUID} = 0 ]; then
  echo "This setup script is expecting to run as a regular user."
  exit 1
fi

if [ "${DESKTOP_SESSION}" = "cinnamon" ]; then
  ~/.dotfiles/scripts/restore_cinnamon_settings.sh
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
#   - Decentraleyes
#   - HTTPS Everywhere
#   - Privacy Badger
#   - Reddit Enhancement Suite
#   - Redirect AMP to HTML
#   - Snowflake
#   - uBlock Origin
#
# Potential additions:
#
#   - AdNauseam
#   - CanvasBlocker
#   - ClearURLs
#   - Privacy Possum
#   - Random User-Agent
