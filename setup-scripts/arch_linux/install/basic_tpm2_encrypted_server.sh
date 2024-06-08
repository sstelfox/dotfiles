#!/bin/bash

set -o errexit
set -o errtrace
set -o pipefail
set -o nounset

function error_handler() {
	echo "Error occurred in $(basename ${BASH_SOURCE[0]}) executing line ${1} with status code ${2}"
}

if [ "${DEBUG:-}" = "true" ]; then
	set -o xtrace
fi

### CONFIG

HOSTNAME="${HOSTNAME:-}"
DOMAIN="${DOMAIN:-stelfox.net}"

PRIMARY_USERNAME="${PRIMARY_USERNAME:-sstelfox}"
USER_SSH_PUBKEY="ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBGP+2BkRQuX8w+vxoTfqIWCA5JUuulbauL+brKfSjVH15L3cYEQ1O9OtNOe0Hq5YOxHOMyzHDUlAAlpD8/F/blE="

SSID="${SSID:-}"
SSID_PASSWORD="${SSID_PASSWORD:-}"

DISK="/dev/sda"
SWAP_SIZE="1024" # 1GB Swap

### SANITY CHECK

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

### SHORTCUT ALIASES & DERIVED CONFIGS

FULL_HOSTNAME="${HOSTNAME}.${DOMAIN}"
PARTED_BASE_CMD="/usr/sbin/parted --script --align optimal --machine --"
ROOT_MNT="/mnt/root"

if [ -n "${HOSTNAME}" ]; then
	if [ -r /root/gen-hostname ]; then
		HOSTNAME="$(cat /root/gen-hostname)"
	elif [ -x "./name_generator.py" ]; then
		HOSTNAME="$(./name_generator.py)"
		echo "${HOSTNAME}" >/root/gen-hostname
	else
		echo 'Hostname needs to be provided'
		exit 127
	fi
fi

### LOCAL ENVIRONMENT SETUP

HASHED_USER_PASSWORD=
HASHED_ROOT_PASSWORD=

if [ -r /root/user-pw-hash -a -r /root/root-pw-hash ]; then
	HASHED_USER_PASSWORD="$(cat /root/user-pw-hash)"
	HASHED_ROOT_PASSWORD="$(cat /root/root-pw-hash)"
else
	# We'll use this both for the installer's root account as well as the
	# administrative and root user of the installed system.
	read -e -p "User/Root account password: " -s -r USER_PASSWORD

	# Generate unique hashes for both accounts, but use the same initial password
	# until it can be changed
	HASHED_USER_PASSWORD=$(echo $USER_PASSWORD | openssl passwd -6 -stdin)
	HASHED_ROOT_PASSWORD=$(echo $USER_PASSWORD | openssl passwd -6 -stdin)
	unset USER_PASSWORD

	echo "${HASHED_USER_PASSWORD}" >/root/user-pw-hash
	echo "${HASHED_ROOT_PASSWORD}" >/root/root-pw-hash
fi

DISK_PASSPHRASE=
if [ -r /root/disk-pw ]; then
	DISK_PASSPHRASE="$(cat /root/disk-pw)"
else
	read -e -p "Encryption Passphrase: " -s -r DISK_PASSPHRASE
	echo

	echo "${DISK_PASSPHRASE}" >/root/disk-pw
fi

usermod --password ${HASHED_ROOT_PASSWORD} root

# Also throw in some SSH keys to make access a tad easier
mkdir -p /root/.ssh
chmod 0700 /root/.ssh
cat <<EOF >/root/.ssh/authorized_keys
${USER_SSH_PUBKEY}
EOF
chmod 0600 /root/.ssh/authorized_keys

systemctl start sshd.service

# Ensure the system clock is updated
timedatectl

# Find some fast mirrors we can use for the install (will also become the
# default mirrors)
reflector --save /etc/pacman.d/mirrorlist --country "US" --protocol https \
	--latest 10 --sort rate --age 12 --fastest 10

### DISK PARTITIONING

/bin/dd bs=1M count=4 status=none if=/dev/zero of=${DISK} oflag=sync
${PARTED_BASE_CMD} ${DISK} mklabel gpt

# Create the system partition
${PARTED_BASE_CMD} ${DISK} unit MiB mkpart ESP 1 513 name 1 '"ESP"' set 1 boot on
${PARTED_BASE_CMD} ${DISK} unit MiB mkpart system 513 -1

dd if=/dev/zero bs=1M count=1 of=${DISK}1 >/dev/null
dd if=/dev/zero bs=1M count=16 of=${DISK}2 >/dev/null

### DISK FORMATTING & ENCRYPTION

mkfs.vfat -F 32 -n EFI ${DISK}1 >/dev/null

echo ${DISK_PASSPHRASE} | cryptsetup --batch-mode --verbose --iter-time 2500 \
	--use-urandom --force-password luksFormat ${DISK}2
sleep 2

echo ${DISK_PASSPHRASE} | cryptsetup luksOpen --allow-discards ${DISK}2 system-root
unset DISK_PASSPHRASE

mkfs.xfs -q -f -L root /dev/mapper/system-root

sync

# Minor settle window
sleep 1

mkdir -p ${ROOT_MNT}
mount /dev/mapper/system-root ${ROOT_MNT}

mkdir -p ${ROOT_MNT}/boot
chmod 0700 ${ROOT_MNT}/boot
mount ${DISK}1 ${ROOT_MNT}/boot -o fmask=177,dmask=077

dd if=/dev/zero of=${ROOT_MNT}/swapfile bs=${SWAP_SIZE}M count=1
chmod 0600 ${ROOT_MNT}/swapfile
mkswap ${ROOT_MNT}/swapfile

sync

swapon ${ROOT_MNT}/swapfile

### BASE INSTALLATION

pacstrap -K ${ROOT_MNT} base dbus-broker-units efibootmgr libfido2 \
	linux-firmware linux-hardened man-db man-pages mkinitcpio networkmanager \
	nftables openssh sbctl sudo tmux vim wireguard-tools xfsprogs \
	zram-generator

# Other packages that I may want to include in my base: git lvm mdadm neovim tpm2-tools

# Create /etc/adjtime before we take any internal operations
arch-chroot ${ROOT_MNT} hwclock --systohc

genfstab -pU ${ROOT_MNT} >>${ROOT_MNT}/etc/fstab

if grep -qi intel /proc/cpuinfo 2>/dev/null; then
	arch-chroot ${ROOT_MNT} pacman -Sy --needed --noconfirm intel-ucode
fi

### LOCALE & KEYMAP

arch-chroot ${ROOT_MNT} ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime

echo 'en_US.UTF-8 UTF-8' >${ROOT_MNT}/etc/locale.gen
arch-chroot ${ROOT_MNT} locale-gen

echo 'LANG=en_US.UTF-8' >${ROOT_MNT}/etc/locale.conf
echo 'KEYMAP=us' >${ROOT_MNT}/etc/vconsole.conf

### NETWORK IDENTITY

echo "${HOSTNAME}" >${ROOT_MNT}/etc/hostname

cat <<EOF >${ROOT_MNT}/etc/hosts
127.0.0.1 ${FULL_HOSTNAME} ${HOSTNAME} localhost4 localhost
::1 ${FULL_HOSTNAME} ${HOSTNAME}       localhost6 localhost
EOF

arch-chroot ${ROOT_MNT} systemctl disable systemd-resolved.service
arch-chroot ${ROOT_MNT} systemctl mask systemd-resolved.service

cat <<EOF >${ROOT_MNT}/etc/resolv.conf
domain ${DOMAIN}

options attempts:2 rotate timeout:2 edns0 no-tld-query

nameserver 1.1.1.1
nameserver 1.0.0.1

nameserver 2606:4700:4700::1001
nameserver 2606:4700:4700::1111
EOF

### USER CREATION & ACCESS CONTROL

arch-chroot ${ROOT_MNT} groupadd -r sudoers
arch-chroot ${ROOT_MNT} groupadd -r sshers
arch-chroot ${ROOT_MNT} usermod --append --groups sshers --password ${HASHED_ROOT_PASSWORD} root
arch-chroot ${ROOT_MNT} useradd --create-home --groups sudoers,sshers --password ${HASHED_ROOT_PASSWORD} ${PRIMARY_USERNAME}

PRIOR_UMASK="$(umask)"
umask 0077

mkdir --parents ${ROOT_MNT}/home/${PRIMARY_USERNAME}/.ssh
cat <<EOF >${ROOT_MNT}/home/${PRIMARY_USERNAME}/.ssh/authorized_keys
${USER_SSH_PUBKEY}
EOF
arch-chroot ${ROOT_MNT} chown -R ${PRIMARY_USERNAME}:${PRIMARY_USERNAME} /home/${PRIMARY_USERNAME}/.ssh

mkdir --parents ${ROOT_MNT}/root/.ssh
cat <<EOF >${ROOT_MNT}/root/.ssh/authorized_keys
${USER_SSH_PUBKEY}
EOF

umask ${PRIOR_UMASK}

# Note: this file can't end in .conf like I'd like it to as any file that
# contains any period is ignored by sudo
cat <<'EOF' >${ROOT_MNT}/etc/sudoers.d/10-default
Cmnd_Alias BLACKLIST = /usr/bin/su
Cmnd_Alias USER_WRITEABLE = /home/*, /tmp/*, /var/tmp/*

Defaults env_reset, ignore_dot, requiretty, use_pty
Defaults !path_info, !use_netgroups

Defaults passwd_timeout = 2
Defaults secure_path = /usr/local/sbin:/usr/local/bin:/usr/bin

%sudoers   ALL=(ALL:ALL)   ALL,!BLACKLIST,!USER_WRITEABLE
EOF

### SERVICE CONFIGURATION

rm -f /etc/ssh/sshd_config.d/99-archlinux.conf

cat <<'EOF' >${ROOT_MNT}/etc/ssh/sshd_config.d/10-default.conf
ClientAliveInterval 20

UsePAM yes
PasswordAuthentication yes

AllowGroups sshers

AllowAgentForwarding no
AllowTcpForwarding no
EOF

arch-chroot ${ROOT_MNT} systemctl enable sshd.service

arch-chroot ${ROOT_MNT} systemctl enable fstrim.timer
arch-chroot ${ROOT_MNT} systemctl enable NetworkManager.service

### RAM COMPRESSION

echo '[zram0]' >${ROOT_MNT}/etc/systemd/zram-generator.conf
arch-chroot ${ROOT_MNT} systemctl enable systemd-zram-setup@zram0.service

### SECURE BOOT

arch-chroot ${ROOT_MNT} sbctl create-keys
if ! arch-chroot ${ROOT_MNT} sbctl enroll-keys --yes-this-might-brick-my-machine &>/dev/null; then
	echo "Failed to enroll boot signature keys in system, maybe setup mode isn't enabled?"
fi

arch-chroot ${ROOT_MNT} sbctl sign -s /usr/lib/systemd/boot/efi/systemd-bootx64.efi

# Create an on-disk disk encryption config
#
# The FIDO/TPM options are only useful if we enroll that type of crypto key into
# the root filesystem. discard is largely ignored during the boot, that needs to
# be set via a kernel cmdline option its here for consistency and for other
# tools knowledge, the workqueue options provide better performance on SSDs for
# encrypted disks.
CRYPTSETUP_ROOT_UUID="$(cryptsetup luksUUID ${DISK}2)"
cat <<EOF >${ROOT_MNT}/etc/crypttab.initramfs
system-root   ${DISK}2  none  discard,fido2-device=auto,no-read-workqueue,no-write-workqueue
EOF

# With TPM unlocking as well:
#system-root   ${DISK}2  none  discard,fido2-device=auto,tpm2-device=auto,no-read-workqueue,no-write-workqueue

# Initramfs config

cat <<'EOF' >${ROOT_MNT}/etc/mkinitcpio.conf
MODULES+=()

# * keyboard is intentionally placed early to always include all keyboard
#   drivers early on before autodetect trims them down.
# * some of my hosts may need lvm2 which should be loaded between sd-encrypt
#   and filesystems
HOOKS=(base systemd keyboard autodetect microcode modconf sd-vconsole block sd-encrypt filesystems fsck)
EOF

# Regenerate the initramfs entries, now signed and with the configuration for
# our encrypted system
arch-chroot ${ROOT_MNT} mkinitcpio -P

arch-chroot ${ROOT_MNT} bootctl install

# Bootloader
cat <<'EOF' >${ROOT_MNT}/boot/loader/loader.conf
default linux-hardened
editor no
timeout 3
EOF

# The /etc/kernel/cmdline file is a red herring, these files need to contain the
# kernel options.
#
# They also need to be manually created for any entries to show up in the
# bootctl managed menu.
#
# The discard needs to be present here if the drive is unlocked by systemd
# during boot (the one in crypttab is kept for consistency and other tools, but
# does not work on boot).
cat <<EOF >${ROOT_MNT}/boot/loader/entries/linux-hardened.conf
title Hardened Linux
linux /vmlinuz-linux-hardened
initrd /intel-ucode.img
initrd /initramfs-linux-hardened.img
options rd.luks.options=discard root=/dev/mapper/system-root zswap.enabled=0 rw rootfstype=xfs
EOF

# resume options were for the swapfile and I need to update them for
#options rd.luks.options=discard root=/dev/mapper/system-root resume=UUID=${RESUME_UUID} resume_offset=${RESUME_OFFSET} zswap.enabled=0 rw rootfstype=xfs

cat <<EOF >${ROOT_MNT}/boot/loader/entries/linux-hardened-fallback.conf
title Hardened Linux (fallback)
linux /vmlinuz-linux-hardened
initrd /initramfs-linux-hardened.img
options root=/dev/mapper/system-root zswap.enabled=0 rw rootfstype=xfs
EOF

# Handles updating the bootloader when necessary, with secure boot enabled we
# need to make sure our kernels are signed before we enable it. With sbctl as
# long as we've enrolled files to be signed in its database, the signing happens
# automatically.
arch-chroot ${ROOT_MNT} systemctl enable systemd-boot-update.service

echo "STOPPED FOR DEBUGGING"
exit 1

umount -lR ${ROOT_MNT}
reboot

# Next boot:
#
# Following boot:
#
# TODO(manual): Enable secure boot
#
# Confirm secure boot status
#
#sbctl status
#
# LUKS recovery key:
#
#systemd-cryptenroll --recovery-key /dev/sda2
#
# This will produce a string of characters that can be used to recover access
# to the paritions should the passphrase or security token be lost. Should be
# protected and stored along-side the UUID of the LUKS drive itself.
#
# TODO(optional): Enroll TPM state into LUKS keystore:
#
# Note: may want to adjust the PCRs being used...
#
# 0: BIOS (Code/Data)
# 1: BIOS Config
# 7: Secure Boot Chain
#
# This needs
#systemd-cryptenroll --tpm2-device=list
#systemd-cryptenroll ${DISK}2 --tpm2-device=auto --tpm2-pcrs=0,1,7
#
# TODO(optional): Enroll FIDO2 key
#
# For an explicit device:
#systemd-cryptenroll --fido2-device=list
#systemd-cryptenroll --fido2-device=${DEVICE_NAME} ${DISK}2
#
# Full auto no-human presence required:
#
#systemd-cryptenroll ${DISK}2 --fido2-device=auto --fido2-with-client-pin=no --fido2-with-user-presence=no
#
# TODO(optional): Confirm automatic reboot works
#
# Following boot:
#
# TODO(optional): Remove manual passphrase
#
#systemd-cryptenroll --wipe-slot=password ${DISK}2
