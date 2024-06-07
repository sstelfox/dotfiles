#!/bin/bash

set -o errexit
set -o nounset

# Setup variable
#SSID="${SSID:-}"
#SSID_PASSWORD="${SSID_PASSWORD:-}"
#HOSTNAME="${HOSTNAME:-naming_needed}"
#DOMAIN="${DOMAIN:-unknown}"
PRIMARY_USERNAME="${PRIMARY_USERNAME:-sstelfox}"

DISK="/dev/sda"
SWAP_SIZE="1024" # 1GB Swap
PARTED_BASE_CMD="/usr/sbin/parted --script --align optimal --machine --"

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

read -e -p "User account password: " -s -r USER_PASSWORD

# Generate unique hashes for both accounts, but use the same initial password
# until it can be changed
HASHED_USER_PASSWORD=$(echo $USER_PASSWORD | openssl passwd -6 -stdin)
HASHED_ROOT_PASSWORD=$(echo $USER_PASSWORD | openssl passwd -6 -stdin)
unset USER_PASSWORD

usermod --password ${HASHED_ROOT_PASSWORD} root

mkdir -p /root/.ssh
chmod 0700 /root/.ssh
cat <<'EOF' >/root/.ssh/authorized_keys
ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBGP+2BkRQuX8w+vxoTfqIWCA5JUuulbauL+brKfSjVH15L3cYEQ1O9OtNOe0Hq5YOxHOMyzHDUlAAlpD8/F/blE=
EOF
chmod 0600 /root/.ssh/authorized_keys

systemctl start sshd.service

# Ensure the system clock is updated
timedatectl

reflector --save /etc/pacman.d/mirrorlist --country "United States,Canada" \
	--protocol https --latest 10

/bin/dd bs=1M count=4 status=none if=/dev/zero of=${DISK} oflag=sync
${PARTED_BASE_CMD} ${DISK} mklabel gpt

# Create the system partition
${PARTED_BASE_CMD} ${DISK} unit MiB mkpart ESP 1 513 name 1 '"ESP"' set 1 boot on
${PARTED_BASE_CMD} ${DISK} unit MiB mkpart system 513 -1

dd if=/dev/zero bs=1M count=1 of=${DISK}1 >/dev/null
dd if=/dev/zero bs=1M count=16 of=${DISK}2 >/dev/null

mkfs.vfat -F 32 -n EFI ${DISK}1 >/dev/null

read -e -p "Encryption Passphrase: " -s -r DISK_PASSPHRASE
echo

echo $DISK_PASSPHRASE | cryptsetup --batch-mode --verbose --type luks2 \
	--pbkdf argon2id --key-size 512 --hash sha512 --iter-time 2500 \
	--use-urandom --force-password luksFormat ${DISK}2

sleep 2

echo ${DISK_PASSPHRASE} | cryptsetup luksOpen --allow-discards ${DISK}2 system-root
unset DISK_PASSPHRASE

sleep 1

mkfs.xfs -q -f -L root /dev/mapper/system-root

mkdir -p /mnt/root
mount /dev/mapper/system-root /mnt/root

mkdir -p /mnt/root/efi
chmod 0700 /mnt/root/efi
mount ${DISK}1 /mnt/root/efi -o fmask=177,dmask=077

dd if=/dev/zero of=/mnt/root/swapfile bs=${SWAP_SIZE}M count=1
chmod 0600 /mnt/root/swapfile
mkswap /mnt/root/swapfile

sync

swapon /mnt/root/swapfile

pacstrap -K /mnt/root base efibootmgr git libfido2 linux-firmware \
	linux-hardened lvm2 man-db man-pages mdadm neovim networkmanager nftables \
	openssh sbctl sudo tpm2-tools tmux wireguard-tools xfsprogs zram-generator

# Create /etc/adjtime before we take any internal operations
arch-chroot /mnt/root hwclock --systohc

genfstab -pU /mnt/root >>/mnt/root/etc/fstab

if grep -qi intel /proc/cpuinfo 2>/dev/null; then
	arch-chroot /mnt/root pacman -Sy --needed --noconfirm intel-ucode
fi

arch-chroot /mnt/root ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime

echo 'en_US.UTF-8 UTF-8' >/mnt/root/etc/locale.gen
arch-chroot /mnt/root locale-gen
echo 'LANG=en_US.UTF-8' >/mnt/root/etc/locale.conf

echo "${HOSTNAME}" >/mnt/root/etc/hostname

cat <<EOF >/mnt/root/etc/hosts
127.0.0.1 ${HOSTNAME} localhost4 localhost
::1 ${HOSTNAME}       localhost6 localhost
EOF

echo 'KEYMAP=us' >/mnt/root/etc/vconsole.conf

arch-chroot /mnt/root groupadd -r sudoers
arch-chroot /mnt/root groupadd -r sshers
arch-chroot /mnt/root usermod --append --groups sudoers --password ${HASHED_ROOT_PASSWORD} root
arch-chroot /mnt/root useradd --create-home --groups sudoers,sshers --password ${HASHED_ROOT_PASSWORD} ${PRIMARY_USERNAME}

arch-chroot /mnt/root systemctl disable systemd-resolved.service
arch-chroot /mnt/root systemctl mask systemd-resolved.service

cat <<EOF >/mnt/root/etc/resolv.conf
domain ${DOMAIN}

options attempts:2 rotate timeout:2 edns0 no-tld-query

nameserver 1.1.1.1
nameserver 1.0.0.1

nameserver 2606:4700:4700::1001
nameserver 2606:4700:4700::1111
EOF

cat <<'EOF' >/mnt/root/etc/ssh/sshd_config
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

cat <<'EOF' >/mnt/root/etc/sudoers
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

echo '[zram0]' >/mnt/root/etc/systemd/zram-generator.conf
arch-chroot /mnt/root systemctl enable systemd-zram-setup@zram0.service

arch-chroot /mnt/root systemctl enable fstrim.timer
arch-chroot /mnt/root systemctl enable NetworkManager.service
arch-chroot /mnt/root systemctl enable sshd.service

RESUME_UUID=$(findmnt -no UUID -T /mnt/root/swapfile)
RESUME_OFFSET=$(filefrag -v /mnt/root/swapfile)

echo "STOPPED FOR DEBUGGING"
exit 1

arch-chroot /mnt/root sbctl create-keys
arch-chroot /mnt/root mkinitcpio -P

# - Bootloader
arch-chroot /mnt/root bootctl install

cat <<'EOF' >/mnt/root/efi/loader/loader.conf
editor no
timeout 3
EOF

# TODO:
#
# - Boot signatures
#?sbctl sign -s /efi/EFI/BOOT/BOOTX64.EFI
sbctl sign -s /usr/lib/systemd/boot/efi/systemd-bootx64.efi

# - mkinitcpio config
#
# Find TPM driver name:
# systemd-cryptenroll --tpm2-device=list
#
# Add drive name to /etc/mkinitcpio.conf modules:
#
#MODULES+=(tpm_tis)
#
# Reference hooks:
#
#HOOKS=(base systemd autodetect keyboard sd-vconsole modconf block sd-encrypt filesystems fsck)
#
# Update the kernel cmdline:
cat <<'EOF' >/mnt/root/etc/kernel/cmdline
rd.luks.name=<UUID>/system-root rd.luks.options=tpm2-device=auto root=/dev/mapper/system-root
EOF

# - generate signed images (happens automatically now)
arch-chroot /mnt/root mkinitcpio -P

# systemd-cryptenroll /dev/mapper/system-root --wipe-slot=password
# Handles updating the bootloader when necessary, with secure boot enabled we
# need to make sure our kernels are signed before we enable it. With sbctl as
# long as we've enrolled files to be signed in its database, the signing happens
# automatically.
arch-chroot /mnt/root systemctl enable systemd-boot-update.service

umount -R /mnt/root
reboot
#
# Next boot:
#
# - Enroll kernel keys into UEFI
#
# sbctl enroll-keys
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
# - Confirm automatic reboot works
#
# Following boot:
#
# - Remove manual passphrase
