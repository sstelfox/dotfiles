#!/bin/bash

# Unfortunately I couldn't get chromium working with selenium so I need to go
# with the full chrome... This will automate that setup but I'm not going to
# add it to fresh_setup.sh as an option.

set -o errexit

if [ ${EUID} != 0 ]; then
  echo "This setup script is expecting to run as root."
  exit 1
fi

dnf install chromedriver fedora-workstation-repositories -y
dnf config-manager --set-enabled google-chrome
dnf install google-chrome-stable -y
