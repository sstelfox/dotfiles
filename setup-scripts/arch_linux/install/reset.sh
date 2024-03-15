#!/bin/bash

set -o nounset

ROOT_MNT="/mnt/root"

DISK1="/dev/nvme0n1"
DISK2="/dev/nvme1n1"

PART1_ID="p1"
PART2_ID="p2"

if [ ${EUID} != 0 ]; then
  echo "This installation script must be as root from an Arch install medium"
  exit 1
fi

overwrite_block_ends() {
  local blk_dev=$1

  dd bs=1M count=636 if=/dev/zero oflag=sync of="${blk_dev}" &>/dev/null || true
  local blk_end="$(blockdev --getsize64 ${blk_dev})"

  if [ "$?" -ne "0" ]; then
    echo "Failed to get size of ${blk_dev}"
    return 0
  fi

  local end_start="$(echo "(${blk_end} / 1048576) - 8" | bc)"
  echo ${end_start}

  dd bs=1M seek=${end_start} count=8 if=/dev/zero oflag=sync of="${blk_dev}" &>/dev/null || true
}

umount -lR ${ROOT_MNT} || true

#overwrite_block_ends /dev/mapper/system-root || true
#overwrite_block_ends /dev/mapper/system-swap || true

lvchange -a n system || true

#overwrite_block_ends /dev/mapper/system-crypt || true
cryptsetup luksClose /dev/mapper/system-crypt || true

#overwrite_block_ends /dev/md/esp
mdadm --stop /dev/md/esp || true

#overwrite_block_ends /dev/md/system
mdadm --stop /dev/md/system || true

overwrite_block_ends ${DISK1}${PART1_ID}
overwrite_block_ends ${DISK1}${PART2_ID}
overwrite_block_ends ${DISK1}

overwrite_block_ends ${DISK2}${PART1_ID}
overwrite_block_ends ${DISK2}${PART2_ID}
overwrite_block_ends ${DISK2}

sync
partprobe
