#/bin/bash

set -o errexit

DISK1="/dev/nvme0n1"
DISK2="/dev/nvme1n1"
SWAP_SIZE="4096" # 4GB Swap
PARTED_BASE_CMD="/usr/sbin/parted --script --align optimal --machine --"

# Function to initialize a disk
initialize_disk() {
	local DISK=$1

	# Clear and reset the partition table
	/bin/dd bs=1M count=4 status=none if=/dev/zero of=${DISK} oflag=sync
	${PARTED_BASE_CMD} ${DISK} mklabel gpt

	# Create the system partition
	${PARTED_BASE_CMD} ${DISK} unit MiB mkpart ESP 1 513 name 1 '"ESP"' set 1 boot on
	${PARTED_BASE_CMD} ${DISK} unit MiB mkpart system 513 -1

	dd if=/dev/zero bs=1M count=1 of=${DISK}p1 >/dev/null
	dd if=/dev/zero bs=1M count=16 of=${DISK}p2 >/dev/null
}

# Initialize both disks
initialize_disk $DISK1
initialize_disk $DISK2

# Create RAID arrays, use metadata at the end of the partitions to ensure maximum compatibility with boot loaders
mdadm --create --verbose /dev/md/esp --metadata=0.90 --level=1 --raid-devices=2 ${DISK1}p1 ${DISK2}p1
mdadm --create --verbose /dev/md/system --level=0 --raid-devices=2 ${DISK1}p2 ${DISK2}p2

# Format the ESP (RAID 1 for redundancy)
mkfs.vfat -F 32 -n EFI /dev/md/esp >/dev/null

read -e -p "Encryption Passphrase: " -s -r DISK_PASSPHRASE
echo

echo $DISK_PASSPHRASE | cryptsetup --verbose --cipher aes-xts-plain64 \
	--key-size 512 --hash sha512 --iter-time 2500 --use-urandom --batch-mode \
	--force-password luksFormat /dev/md/system

echo ${DISK_PASSPHRASE} | cryptsetup luksOpen --allow-discards /dev/md/system system-crypt
unset DISK_PASSPHRASE

pvcreate -ff -y --zero y /dev/mapper/system-crypt >/dev/null
vgcreate system /dev/mapper/system-crypt >/dev/null

AVAILABLE_VG_SPACE="$(vgdisplay --units m system | grep 'VG Size' | awk '{ print $(NF-1) }')"
ROOT_SIZE="$((${AVAILABLE_VG_SPACE%.*} - ${SWAP_SIZE}))"

# Note to self, I added the --yes flag based on a comment in the man page but
# it wasn't actually listed in the available options for lvcreate. This hasn't
# been tested and may break. I was trying to deal with the script still
# interactively asking me if I wanted to wipe the swap signature even with
# --wipesignatures y
lvcreate -L ${ROOT_SIZE}M --wipesignatures y --yes -n root system >/dev/null
lvcreate -l 100%FREE --wipesignatures y --yes -n swap system >/dev/null

# Just in case refresh our logical lists
lvscan >/dev/null

mkfs.xfs -q -f -L root /dev/mapper/system-root
mkswap -f /dev/mapper/system-swap >/dev/null

sync
