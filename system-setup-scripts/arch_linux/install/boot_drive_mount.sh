#/bin/bash

set -o errexit

BOOT_DISK=/dev/sda

mkdir -p /mnt/boot
mount -o ro /dev/mapper/ventoy /mnt/boot
