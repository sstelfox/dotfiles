#!/bin/bash

set -o errexit
set -o nounset

ROOT_MNT="/mnt/root"
DOMAIN="stelfox.net"
PRIMARY_USERNAME="sstelfox"

HOSTNAME="$(./name_generator.py)"
FULL_HOSTNAME="${HOSTNAME}.${DOMAIN}"

if [ ${EUID} != 0 ]; then
  echo "This installation script must be as root from an Arch install medium"
  exit 1
fi

if [ "$(cat /etc/hostname)" != "archiso" ]; then
  echo "This installation script must be run from an Arch install medium"
  exit 2
fi

if ! mount 2>/dev/null | grep -q /mnt/root; then
  echo "Root filesystem does not appear to be mounted"
  exit 3
fi

read -e -p "User account password: " -s -r USER_PASSWORD

# Generate unique hashes for both accounts, but use the same initial password
# until it can be changed
HASHED_USER_PASSWORD=$(echo $USER_PASSWORD | openssl passwd -6 -stdin)
HASHED_ROOT_PASSWORD=$(echo $USER_PASSWORD | openssl passwd -6 -stdin)
USER_PASSWORD=""

#reflector --save /etc/pacman.d/mirrorlist --country "United States,Canada" \
#	--protocol https --latest 10

reflector --save /etc/pacman.d/mirrorlist --country "US" --protocol https --latest 10 --sort rate --age 12 --fastest 10

# Core install always present
pacstrap -K ${ROOT_MNT} base efibootmgr git libfido2 linux-firmware \
  linux-hardened lvm2 man-db man-pages mdadm neovim networkmanager nftables \
  openssh sbctl sudo tmux wireguard-tools xfsprogs zram-generator

genfstab -pU ${ROOT_MNT} >>${ROOT_MNT}/etc/fstab

DISK="/dev/nvme0n1p2"
cat <<EOF >${ROOT_MNT}/etc/crypttab.initramfs
system-root   ${DISK}  none  discard,no-read-workqueue,no-write-workqueue
EOF

arch-chroot ${ROOT_MNT} ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime

echo 'en_US.UTF-8 UTF-8' >${ROOT_MNT}/etc/locale.gen
arch-chroot ${ROOT_MNT} locale-gen
echo 'LANG=en_US.UTF-8' >${ROOT_MNT}/etc/locale.conf

echo "${FULL_HOSTNAME}" >${ROOT_MNT}/etc/hostname

cat <<EOF >${ROOT_MNT}/etc/hosts
127.0.0.1 ${FULL_HOSTNAME} ${HOSTNAME} localhost4 localhost
::1 ${FULL_HOSTNAME} ${HOSTNAME}       localhost6 localhost
EOF

echo 'KEYMAP=us' >${ROOT_MNT}/etc/vconsole.conf

arch-chroot ${ROOT_MNT} groupadd -r sudoers || true
arch-chroot ${ROOT_MNT} groupadd -r sshers || true
arch-chroot ${ROOT_MNT} usermod --append --groups sudoers --password ${HASHED_ROOT_PASSWORD} root || true
arch-chroot ${ROOT_MNT} useradd --create-home --groups sudoers,sshers --password ${HASHED_ROOT_PASSWORD} ${PRIMARY_USERNAME} || true

cat <<EOF >${ROOT_MNT}/etc/resolv.conf
domain ${DOMAIN}

options attempts:2 rotate timeout:2 edns0 no-tld-query

nameserver 1.1.1.1
nameserver 1.0.0.1

nameserver 2606:4700:4700::1001
nameserver 2606:4700:4700::1111
EOF

cat <<EOF >${ROOT_MNT}/etc/ssh/sshd_config
AddressFamily any

Port 22

ClientAliveInterval 10

UsePAM yes
PermitEmptyPasswords no
PermitRootLogin prohibit-password

AllowGroups sshers
AuthorizedKeysFile .ssh/authorized_keys
PreferredAuthentications publickey,keyboard-interactive,password

AllowTcpForwarding no

Subsystem sftp /usr/lib/ssh/sftp-server
EOF

cat <<EOF >${ROOT_MNT}/etc/sudoers
Cmnd_Alias BLACKLIST = /sbin/su
Cmnd_Alias USER_WRITEABLE = /home/*, /tmp/*, /var/tmp/*

Defaults env_reset, ignore_dot, requiretty, use_pty, noexec
Defaults !path_info, !use_netgroups, !visiblepw

Defaults env_keep += "TZ"
Defaults passwd_timeout = 2
Defaults secure_path = /sbin:/bin:/usr/sbin:/usr/bin

root       ALL=(ALL)   ALL
%sudoers   ALL=(ALL)   ALL,!BLACKLIST,!USER_WRITEABLE
EOF

echo '[zram0]' >${ROOT_MNT}/etc/systemd/zram-generator.conf

arch-chroot ${ROOT_MNT} systemctl disable systemd-resolved.service
arch-chroot ${ROOT_MNT} systemctl mask systemd-resolved.service
arch-chroot ${ROOT_MNT} systemctl enable fstrim.timer
arch-chroot ${ROOT_MNT} systemctl enable NetworkManager.service
arch-chroot ${ROOT_MNT} systemctl enable sshd.service
arch-chroot ${ROOT_MNT} systemctl enable systemd-timesyncd.service
arch-chroot ${ROOT_MNT} systemctl enable systemd-zram-setup@zram0.service

# Swap based suspend/resume (resume hook & kernel opts)
RESUME_UUID=$(findmnt -no UUID -T ${ROOT_MNT}/swapfile)
RESUME_OFFSET=$(filefrag -v ${ROOT_MNT}/swapfile)

arch-chroot ${ROOT_MNT} sbctl create-keys

if ! arch-chroot ${ROOT_MNT} sbctl enroll-keys --yes-this-might-brick-my-machine &>/dev/null; then
  echo "Failed to enroll boot signature keys in system, maybe setup mode isn't enabled?"
fi

arch-chroot ${ROOT_MNT} sbctl sign -s /usr/lib/systemd/boot/efi/systemd-bootx64.efi

cat <<EOF >${ROOT_MNT}/etc/mkinitcpio.conf
MODULES=()
BINARIES=()
FILES=()

# * keyboard is intentionally placed early to always include all keyboard drivers early on before
#   autodetect trims them down.
# * some of my hosts may need lvm2 which should be loaded between sd-encrypt and filesystems
HOOKS=(base systemd keyboard autodetect microcode modconf sd-vconsole block sd-encrypt filesystems fsck)
EOF

mkdir -p ${ROOT_MNT}/boot/loader/entries

cat <<EOF >${ROOT_MNT}/boot/loader/loader.conf
default linux-hardened
editor no
timeout 3
EOF

# The /etc/kernel/cmdline file is a red herring, these files need to contain the
# kernel options.
#
# They also need to be manually created for any entries to show up in the
# bootctl managed menu.

# The discard needs to be present here if the drive is unlocked by systemd
# during boot (the one in crypttab is kept for consistency and other tools, but
# does not work on boot).
cat <<EOF >${ROOT_MNT}/boot/loader/entries/linux-hardened.conf
title Hardened Linux

linux /vmlinuz-linux-hardened
initrd /intel-ucode.img
initrd /initramfs-linux-hardened.img

options rd.luks.options=discard root=/dev/system/root resume=UUID=${RESUME_UUID} resume_offset=${RESUME_OFFSET}
EOF

cat <<EOF >${ROOT_MNT}/boot/loader/entries/linux-hardened-fallback.conf
title Hardened Linux (fallback)

linux /vmlinuz-linux-hardened
initrd /initramfs-linux-hardened.img

options root=/dev/mapper/system-root rw rootfstype=xfs zswap.enabled=0
EOF

arch-chroot ${ROOT_MNT} mkinitcpio -P
arch-chroot ${ROOT_MNT} bootctl --no-variables install

# Handles updating the bootloader when necessary, with secure boot enabled we
# need to make sure our kernels are signed before we enable it. With sbctl as
# long as we've enrolled files to be signed in its database, the signing happens
# automatically.
arch-chroot ${ROOT_MNT} systemctl enable systemd-boot-update.service
