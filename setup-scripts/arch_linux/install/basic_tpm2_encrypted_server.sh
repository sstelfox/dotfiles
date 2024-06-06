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

systemctl start sshd.service

sleep 2
echo 'IP Addresses:'
ip -4 addr

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

echo ${DISK_PASSPHRASE} | cryptsetup luksOpen --allow-discards ${DISK}2 system-crypt
unset DISK_PASSPHRASE

pvcreate -ff -y --zero y /dev/mapper/system-crypt >/dev/null
vgcreate system /dev/mapper/system-crypt >/dev/null

lvcreate -l 100%FREE --wipesignatures y --yes -n root system >/dev/null

# Just in case refresh our logical lists
lvscan >/dev/null

sleep 1

mkfs.xfs -q -f -L root /dev/mapper/system-root

mkdir -p /mnt/root
mount /dev/mapper/system-root /mnt/root

mkdir -p /mnt/root/efi
chmod 0700 /mnt/root/efi

mount ${DISK}1 /mnt/root/efi

dd if=/dev/zero of=/mnt/root/swapfile bs=${SWAP_SIZE}M count=1
chmod 0600 /mnt/root/swapfile
mkswap /mnt/root/swapfile

sync

swapon /mnt/root/swapfile

pacstrap -K /mnt/root base efibootmgr git libfido2 linux-firmware \
	linux-hardened lvm2 man-db man-pages mdadm neovim networkmanager nftables \
	openssh sbctl sudo tmux wireguard-tools xfsprogs zram-generator

genfstab -pU /mnt/root >>/mnt/root/etc/fstab

arch-chroot /mnt/root ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime

echo 'en_US.UTF-8 UTF-8' >/mnt/root/etc/locale.gen
arch-chroot /mnt/root locale-gen
echo 'LANG=en_US.UTF-8' >/mnt/root/etc/locale.conf

echo "${HOSTNAME}" >/mnt/root/etc/hostname

cat <<EOF >${ROOT_MNT}/etc/hosts
127.0.0.1 ${HOSTNAME} localhost4 localhost
::1 ${HOSTNAME}       localhost6 localhost
EOF

echo 'KEYMAP=us' >${ROOT_MNT}/etc/vconsole.conf

# TODO: swapfile & zram

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

# TODO: bootloader & unified kernel images
arch-chroot /mnt/root bootctl install

arch-chroot /mnt/root mkinitcpio -P

umount -R /mnt/root
reboot
