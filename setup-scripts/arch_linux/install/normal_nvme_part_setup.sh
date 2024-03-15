#/bin/bash

set -o errexit
set -o nounset

DISK1="/dev/nvme0n1"

PART1_ID="p1"
PART2_ID="p2"

SWAP_SIZE="4096"

PARTED_BASE_CMD="/usr/sbin/parted --script --align optimal --machine --"

# Function to initialize a disk
initialize_disk() {
  local disk=$1
  
  # Clear and reset the partition table
  dd bs=1M count=4 status=none if=/dev/zero of=${disk} oflag=sync

  ${PARTED_BASE_CMD} ${disk} mklabel gpt || true
  
  # Create the system partition
  ${PARTED_BASE_CMD} ${disk} unit MiB mkpart ESP 1 513 name 1 '"ESP"' set 1 boot on || true
  ${PARTED_BASE_CMD} ${disk} unit MiB mkpart system 513 -1 || true
  
  dd if=/dev/zero bs=1M count=16 of=${disk}${PART1_ID} >/dev/null || true
  dd if=/dev/zero bs=1M count=16 of=${disk}${PART2_ID} >/dev/null || true
}

initialize_disk $DISK1

# Format the ESP (RAID 1 for redundancy)
mkfs.vfat -F 32 -n EFI ${DISK1}${PART1_ID} >/dev/null

read -e -p "Encryption Passphrase: " -s -r DISK_PASSPHRASE
echo

echo $DISK_PASSPHRASE | cryptsetup --batch-mode --verbose --type luks2 \
  --pbkdf argon2id --key-size 512 --hash sha512 --iter-time 2500 \
  --use-urandom --force-password luksFormat ${DISK1}${PART2_ID}

sleep 2

echo ${DISK_PASSPHRASE} | cryptsetup luksOpen --allow-discards ${DISK1}${PART2_ID} system-crypt
unset DISK_PASSPHRASE

pvcreate -ff -y --zero y /dev/mapper/system-crypt >/dev/null
vgcreate system /dev/mapper/system-crypt >/dev/null

lvcreate -L 50G --wipesignatures y --yes -n root system >/dev/null
lvcreate -l 100%FREE --wipesignatures y --yes -n home system >/dev/null

# Just in case refresh our logical lists
lvscan >/dev/null

sleep 1

mkfs.xfs -q -f -L root /dev/mapper/system-root
mkfs.xfs -q -f -L home /dev/mapper/system-home

mkdir -p /mnt/root
mount /dev/mapper/system-root /mnt/root

mkdir -p /mnt/root/{efi,home,root}
chmod 0700 /mnt/root/{efi,root}
chmod 0711 /mnt/root/home

mount ${DISK1}${PART1_ID} /mnt/root/efi
mount /dev/mapper/system-home /mnt/root/home

# Create a swapfile instead of a dedicate partition
dd if=/dev/zero of=/mnt/root/swapfile bs=4G count=1
chmod 0600 /mnt/root/swapfile
mkswap /mnt/root/swapfile

sync
