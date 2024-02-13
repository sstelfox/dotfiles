#!/bin/bash

set -o errexit
set -o nounset

# Setup variable
SSID="${SSID:-}"
SSID_PASSWORD="${SSID_PASSWORD:-}"
HOSTNAME="${HOSTNAME:-naming_needed.stelfox.net}"

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

systemctl start sshd.service

reflector --save /etc/pacman.d/mirrorlist --country "United States,Canada" \
	--protocol https --latest 10

# TODO: partition setup & mounting
# TODO: bootloader & unified kernel images
# TODO: swapfile & zram
# TODO: root password
# TODO: user account & sudoers
# TODO: graphics drivers? sddm?, pulseaudio?

pacstrap -K /mnt base git kde-graphics-meta kde-network-meta kde-system-meta \
	kde-utilities-meta linux-hardened linux-firmware lvm2 man-db mdadm neovim \
	nftables plasma-desktop tmux firefox

echo 'en_US.UTF-8 UTF-8' >/mnt/etc/locale.gen
arch-chroot /mnt locale-gen

echo 'LANG=en_US.UTF-8' >/mnt/etc/locale.conf
echo 'KEYMAP=us' >/mnt/etc/vconsole.conf
echo "${HOSTNAME}" >/mnt/etc/hostname

# archinstall packages for KDE are plasma-meta konsole kwrite dolphin ark plasma-wayland-session egl-wayland

# May want: network-manager, xorg-wayland

arch-chroot /mnt ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime

arch-chroot /mnt systemctl disable systemd-resolved.service
arch-chroot /mnt systemctl mask systemd-resolved.service

cat <<'EOF' >/mnt/etc/resolv.conf
nameserver 1.1.1.1
nameserver 1.0.0.1
EOF

arch-chroot /mnt systemctl enable sshd.service

# Probably not needed as pacstrap handles this but better safe than sorry
arch-chroot /mnt mkinitcpio -P

umount -R /mnt
reboot
