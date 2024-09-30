#!/bin/bash

set -o errexit

if [ ${EUID} != 0 ]; then
  echo "This setup script is expecting to run as root."
  exit 1
fi

dnf install arm-none-eabi-gcc-cs arm-none-eabi-gcc-cs-c++ \
  arm-none-eabi-binutils-cs gdb kicad kicad-packages3d openocd -y

# Group for accessing serial issues
if ! groups | grep -q dialout; then
  usermod -aG dialout sstelfox
fi

cat << 'EOF' > /etc/udev/rules.d/99-st-link.rules
# ST-LINK/V2
ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3748", MODE:="0660", OWNER="root", GROUP="dialout"

# ST-LINK/V2.1
ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374b", MODE:="0660", OWNER="root", GROUP="dialout"
EOF

udevadm control --reload-rules

# TODO: This doesn't seem to be working right now... keystone-engine isn't happy on F30+...
# Install and setup GEF
#pip3 install --user unicorn capstone ropper keystone-engine
#wget -q -O- https://github.com/hugsy/gef/raw/master/scripts/gef.sh | sh

su -l sstelfox -c /bin/bash -c 'mkdir -p ~/workspace/electronics'
