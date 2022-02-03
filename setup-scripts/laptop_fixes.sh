#!/bin/bash

set -o errexit

if [ ${EUID} != 0 ]; then
  echo "This setup script is expecting to run as root."
  exit 1
fi

# TODO: firmware fixes, power optimization, automatic firmware updating
#sudo dnf install acpica-tools libva-intel-driver tlp fwupd -y

# Touchpad fix
#grubby --update-kernel=ALL --args="psmouse.synaptics_intertouch=1"
