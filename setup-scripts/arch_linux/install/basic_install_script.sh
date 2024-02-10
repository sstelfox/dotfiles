#!/bin/bash

set -o errexit
set -o nounset

# Setup variable
SSID="${SSID:-}"
SSID_PASSWORD="${SSID_PASSWORD:-}"

if [ ${EUID} != 0 ]; then
	echo "This installation script must be as root from an Arch install medium"
	exit 1
fi

SYSTEM_HOSTNAME="$(cat /etc/hostname)"
if [ "${SYSTEM_HOSTNAME}" != "archiso" ]; then
	echo "This installation script must be run from an Arch install medium"
	exit 2
fi

if [ -n "${SSID}" -a -n "${SSID_PASSWORD}" ]; then
	iwctl --passphrase "${SSID_PASSWORD}" station wlan0 connect "${SSID}"
else
	echo "No wifi configured, assuming ethernet connection..."
fi

reflector --save /etc/pacman.d/mirrorlist --country "United States,Canada" \
	--protocol https --latest 10

# TODO: partition setup
# TODO: bootloader & unified kernel images
# TODO: swapfile & zram
# TODO: hostname
# TODO: root password
# TODO: user account & sudoers
# TODO: timezone
# TODO: graphics drivers? sddm?, pulseaudio?

pacstrap -K /mnt base git kde-graphics-meta kde-network-meta kde-system-meta \
	kde-utilities-meta linux-hardened linux-firmware lvm2 man-db mdadm neovim \
	plasma-desktop tmux

# archinstall packages for KDE are plasma-meta konsole kwrite dolphin ark plasma-wayland-session egl-wayland

# May want: network-manager, xorg-wayland
