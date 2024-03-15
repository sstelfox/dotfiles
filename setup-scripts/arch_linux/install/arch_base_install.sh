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
	openssh sudo tmux wireguard-tools xfsprogs zram-generator

genfstab -pU ${ROOT_MNT} >> ${ROOT_MNT}/etc/fstab

arch-chroot ${ROOT_MNT} ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime

echo 'en_US.UTF-8 UTF-8' >${ROOT_MNT}/etc/locale.gen
arch-chroot ${ROOT_MNT} locale-gen
echo 'LANG=en_US.UTF-8' >${ROOT_MNT}/etc/locale.conf

echo "${FULL_HOSTNAME}" >${ROOT_MNT}/etc/hostname

cat <<EOF>${ROOT_MNT}/etc/hosts
127.0.0.1 ${FULL_HOSTNAME} ${HOSTNAME} localhost4 localhost
::1 ${FULL_HOSTNAME} ${HOSTNAME}       localhost6 localhost
EOF

echo 'KEYMAP=us' >${ROOT_MNT}/etc/vconsole.conf

arch-chroot ${ROOT_MNT} groupadd -r sudoers
arch-chroot ${ROOT_MNT} groupadd -r sshers
arch-chroot ${ROOT_MNT} usermod --append --groups sudoers --password ${HASHED_ROOT_PASSWORD} root
# Note: I don't know if audio, video, or storage is actually necessary
arch-chroot ${ROOT_MNT} useradd --create-home --groups audio,video,storage,sudoers,sshers --password ${HASHED_ROOT_PASSWORD} ${PRIMARY_USERNAME}

cat <<EOF >${ROOT_MNT}/etc/resolv.conf
domain ${DOMAIN}

options attempts:2 rotate timeout:2 edns0 no-tld-query

nameserver 1.1.1.1
nameserver 1.0.0.1

nameserver 2606:4700:4700::1001
nameserver 2606:4700:4700::1111
EOF

cat <<EOF>${ROOT_MNT}/etc/ssh/sshd_config
AddressFamily any

Port 22
Port 2200

ClientAliceInterval 10

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

# TODO: signed kernel

cat << EOF > ${ROOT_MNT}/etc/vconsole.conf
KEYMAP=us
EOF

echo '[zram0]' > ${ROOT_MNT}/etc/systemd/zram-generator.conf

arch-chroot ${ROOT_MNT} systemctl disable systemd-resolved.service
arch-chroot ${ROOT_MNT} systemctl mask systemd-resolved.service
arch-chroot ${ROOT_MNT} systemctl enable fstrim.timer
arch-chroot ${ROOT_MNT} systemctl enable NetworkManager.service
arch-chroot ${ROOT_MNT} systemctl enable sshd.service
arch-chroot ${ROOT_MNT} systemctl enable systemd-timesyncd.service
arch-chroot ${ROOT_MNT} systemctl enable systemd-zram-setup@zram0.service

# Swap based suspend/resume (resume hook & kernel opts)
RESUME_UUID=$(findmnt -no UUID -T /mnt/root/swapfile)
RESUME_OFFSET=$(filefrag -v /mnt/root/swapfile)

cp mkinitcpio.conf ${ROOT_MNT}/etc/mkinitcpio.conf
cat<<EOF>${ROOT_MNT}/etc/mkinitcpio.conf
MODULES=()
BINARIES=()
FILES=()

##   This setup assembles a mdadm array with an encrypted root file system.
##   Note: See 'mkinitcpio -H mdadm_udev' for more information on RAID devices.
#    HOOKS=(base udev modconf keyboard keymap consolefont block mdadm_udev encrypt filesystems fsck)

#HOOKS=(base systemd autodetect microcode modconf kms keyboard sd-vconsole block sd-encrypt lvm2 filesystems fsck resume)
HOOKS=(base udev autodetect microcode modconf kms keyboard keymap block encrypt lvm2 filesystems fsck resume)

MODULES_DECOMPRESS="yes"
EOF

#cat <<EOF>${ROOT_MNT}/etc/mkinitcpio.conf.d/linux-hardened.preset
## mkinitcpio preset file for the 'linux-hardened' package
#
#ALL_config="/etc/mkinitcpio.conf"
#ALL_kver="/boot/vmlinuz-linux-hardened"
#
#PRESETS=('default' 'fallback')
#
##default_config="/etc/mkinitcpio.conf"
##default_image="/boot/initramfs-linux-hardened.img"
#default_uki="/efi/EFI/Linux/arch-linux-hardened.efi"
##default_options="--splash /usr/share/systemd/bootctl/splash-arch.bmp"
#
##fallback_config="/etc/mkinitcpio.conf"
#fallback_image="/boot/initramfs-linux-hardened-fallback.img"
##fallback_uki="/efi/EFI/Linux/arch-linux-hardened-fallback.efi"
#fallback_options="-S autodetect"
#EOF

LUKS_UUID="$(lsblk --json --bytes --output UUID,PATH | jq -r .blockdevices[] | select(.path == "/dev/nvme0n1p2").uuid)"
#LUKS_UUID="$(cryptsetup luksUUID /dev/nvme0n1p2)"
LUKS_NAME="${LUKS_UUID}:system-crypt"

cat<<EOF>${ROOT_MNT}/efi/loader/loader.conf
#timeout 3
#console-mode keep

options cryptdevice=UUID=${LUKS_NAME} root=/dev/system/root resume=UUID=${RESUME_UUID} resume_offset=${RESUME_OFFSET} zswap.enabled=0
EOF

arch-chroot ${ROOT_MNT} mkinitcpio -P

# requires extra systemd modules in mkinitcpio
#systemd-cryptenroll --fido2-device=list
#The above has a device name we'll need
#systemd-cryptenroll --fido2-device=/dev/somepath /dev/nvme0n1p2

arch-chroot ${ROOT_MNT} bootctl --no-variables install
