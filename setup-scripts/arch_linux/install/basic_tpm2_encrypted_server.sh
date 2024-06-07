#!/bin/bash

set -o errexit
set -o nounset

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
	if [ -x "./name_generator.py" ]; then
		HOSTNAME="$(./name_generator.py)"
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
fi

DISK_PASSPHRASE=
if [ -r /root/disk-pw ]; then
	DISK_PASSPHRASE="$(cat /root/disk-pw)"
else
	read -e -p "Encryption Passphrase: " -s -r DISK_PASSPHRASE
	echo
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

echo $DISK_PASSPHRASE | cryptsetup --batch-mode --verbose --type luks3 \
	--pbkdf argon2id --key-size 512 --hash sha512 --iter-time 2500 \
	--use-urandom --force-password luksFormat ${DISK}2

sleep 2

echo ${DISK_PASSPHRASE} | cryptsetup luksOpen --allow-discards ${DISK}2 system-root
unset DISK_PASSPHRASE

# Minor settle window
sleep 1

mkfs.xfs -q -f -L root /dev/mapper/system-root

mkdir -p ${ROOT_MNT}
mount /dev/mapper/system-root ${ROOT_MNT}

mkdir -p ${ROOT_MNT}/efi
chmod 0700 ${ROOT_MNT}/efi
mount ${DISK}1 ${ROOT_MNT}/efi -o fmask=177,dmask=077

dd if=/dev/zero of=${ROOT_MNT}/swapfile bs=${SWAP_SIZE}M count=1
chmod 0600 ${ROOT_MNT}/swapfile
mkswap ${ROOT_MNT}/swapfile

sync

swapon ${ROOT_MNT}/swapfile

# We'll need these later for power suspension/resumption if we want to use it
RESUME_UUID=$(findmnt -no UUID -T ${ROOT_MNT}/swapfile)
RESUME_OFFSET=$(filefrag -v ${ROOT_MNT}/swapfile)

### BASE INSTALLATION

pacstrap -K ${ROOT_MNT} base efibootmgr git libfido2 linux-firmware \
	linux-hardened lvm2 man-db man-pages mdadm neovim networkmanager nftables \
	openssh sbctl sudo tpm2-tools tmux wireguard-tools xfsprogs zram-generator

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
arch-chroot ${ROOT_MNT} usermod --append --groups sudoers --password ${HASHED_ROOT_PASSWORD} root
arch-chroot ${ROOT_MNT} useradd --create-home --groups sudoers,sshers --password ${HASHED_ROOT_PASSWORD} ${PRIMARY_USERNAME}

PRIOR_UMASK="$(umask)"
umask 0700

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

cat <<'EOF' >${ROOT_MNT}/etc/sudoers
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

### SERVICE CONFIGURATION

cat <<'EOF' >${ROOT_MNT}/etc/ssh/sshd_config
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

arch-chroot ${ROOT_MNT} systemctl enable sshd.service

arch-chroot ${ROOT_MNT} systemctl enable fstrim.timer
arch-chroot ${ROOT_MNT} systemctl enable NetworkManager.service

### RAM COMPRESSION

echo '[zram0]' >${ROOT_MNT}/etc/systemd/zram-generator.conf
arch-chroot ${ROOT_MNT} systemctl enable systemd-zram-setup@zram0.service

arch-chroot ${ROOT_MNT} sbctl create-keys

if ! arch-chroot ${ROOT_MNT} sbctl enroll-keys --yes-this-might-brick-my-machine &>/dev/null; then
	echo "Failed to enroll boot signature keys in system, maybe setup mode isn't enabled?"
fi

# Bootloader
arch-chroot ${ROOT_MNT} bootctl install

cat <<'EOF' >${ROOT_MNT}/efi/loader/loader.conf
editor no
timeout 3
EOF

# Boot signatures
arch-chroot ${ROOT_MNT} sbctl sign -s /efi/EFI/BOOT/BOOTX64.EFI
arch-chroot ${ROOT_MNT} sbctl sign -s /usr/lib/systemd/boot/efi/systemd-bootx64.efi

# mkinitcpio config

# Find TPM driver name:
#
#systemd-cryptenroll --tpm2-device=list
#
# For now I'm just going to assume its using the most common tpm_tis rather than autodetecting it...
# Add drive name to /etc/mkinitcpio.conf modules:
cat <<'EOF' >${ROOT_MNT}/etc/mkinitcpio.conf
#MODULES+=(tpm_tis)

# * keyboard is intentionally placed early to always include all keyboard
#   drivers early on before autodetect trims them down.
# * some of my hosts may need lvm2 which should be loaded before filesystems
# * some of my hosts may need mdadm which should be placed after block
HOOKS=(base systemd keyboard autodetect microcode kms sd-vconsole modconf block sd-encrypt filesystems fsck)
EOF

# Update the kernel cmdline:
CRYPTSETUP_ROOT_UUID="$(cryptsetup luksUUID ${DISK}2)"
cat <<EOF >${ROOT_MNT}/etc/kernel/cmdline
rd.luks.name=${CRYPTSETUP_ROOT_UUID}/system-root rd.luks.options=tpm3-device=auto root=/dev/mapper/system-root resume=UUID=${RESUME_UUID} resume_offset=${RESUME_OFFSET} zswap.enabled=0
EOF

# - generate signed images (happens automatically now)
arch-chroot ${ROOT_MNT} mkinitcpio -P

# systemd-cryptenroll /dev/mapper/system-root --wipe-slot=password

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
# - Enable secure boot
# - Confirm secure boot status
# - Add recovery key to LUKS keystore & transfer it elsewhere
#
# systemd-cryptenroll /dev/mapper/system-root --recovery-key
#
# - Enroll TPM state into LUKS keystore:
#
# Note: may want to adjust the PCRs being used...
# systemd-cryptenroll /dev/mapper/system-root --tpm2-device=auto --tpm2-pcrs=0,7
#
# - Enroll FIDO3 key
#
# Find the device name we need for the next step
#systemd-cryptenroll --fido2-device=list
#systemd-cryptenroll --fido2-device=${DEVICE_NAME} /dev/sda2
#
# - Confirm automatic reboot works
#
# Following boot:
#
# - Remove manual passphrase
