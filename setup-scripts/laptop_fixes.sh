#!/bin/bash

set -o errexit

if [ ${EUID} != 0 ]; then
  echo "This setup script is expecting to run as root."
  exit 1
fi

# Touchpad fix
grubby --update-kernel=ALL --args="psmouse.synaptics_intertouch=1"
