#!/bin/bash

source setup-setups/_root_prelude.sh

# Note this embedded profile should be run after rust so I can detect if its
# installed and add the appropriate toolchains.

dnf copr enable @kicad/kicad -y
dnf install arm-none-eabi-cs arm-none-eabi-gcc-cs-c++ arm-non-eabi-binutils-cs gdb kicad kicad-packages3d openocd -y

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

# This doesn't seem to be working right now...
# Install and setup GEF
#pip3 install --user unicorn capstone ropper keystone-engine
#wget -q -O- https://github.com/hugsy/gef/raw/master/scripts/gef.sh | sh

if which rustup > /dev/null; then
  rustup target add --toolchain stable thumbv6m-none-eabi
  rustup target add --toolchain nightly thumbv6m-none-eabi

  cargo install cargo-binutils itm
  rustup component add llvm-tools-preview
fi
