#!/bin/bash

set -o errexit

if [ ${EUID} != 0 ]; then
  echo "This setup script is expecting to run as root."
  exit 1
fi

# Note this embedded profile should be run after rust so I can detect if its
# installed and add the appropriate toolchains.

dnf copr enable @kicad/kicad -y
dnf install arm-none-eabi-gcc-cs arm-none-eabi-gcc-cs-c++ arm-none-eabi-binutils-cs gdb kicad kicad-packages3d openocd -y

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
