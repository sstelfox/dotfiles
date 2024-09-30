#!/bin/bash

set -o errexit

if [ ${EUID} != 0 ]; then
	echo "This setup script is expecting to run as root."
	exit 1
fi

# Needed for cargo-deny
dnf install perl-File-Compare perl-FindBin -y

# Needed for sunset-cavern project, systemd-devel provides libudev.h which was
# required by libudev-sys
#dnf install alsa-lib-devel systemd-devel -y

# This package isn't available anymore
#dnf install sccache -y

dnf install clang cmake openssl -y
