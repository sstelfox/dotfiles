#!/bin/bash

set -o errexit

if [ ${EUID} != 0 ]; then
	echo "This setup script is expecting to run as root."
	exit 1
fi

dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm -y

dnf install https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y
