#!/bin/bash

set -o errexit
set -o nounset

ROOT_MNT="/mnt/root"

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

arch-chroot ${ROOT_MNT} pacman -Sy --needed --noconfirm mesa xf86-video-amdgpu libva-mesa-driver \
  vulkan-radeon sddm plasma-meta kde-applications-meta networkmanager-qt powerdevil firefox \
  wl-clipboard alacritty

arch-chroot ${ROOT_MNT} pacman -Sy --needed --noconfirm restic nfs-utils

arch-chroot ${ROOT_MNT} systemctl enable sddm.service

# Disable the system wide suspension on a timer (in graphical environments)
mkdir -p ${ROOT_MNT}/etc/systemd/logind.conf.d
cat <<EOF >${ROOT_MNT}/etc/systemd/logind.conf.d/no-idle-suspend.conf
[Login]
IdleAction=ignore
IdleActionSec=0
HandlePowerKey=poweroff
HandleSuspendKey=suspend
HandleHibernateKey=hibernate
HandleLidSwitch=suspend
HandleLidSwitchExternalPower=suspend
HandleLidSwitchDocked=ignore
EOF

# And configure KDE's default to not have a suspension either
mkdir -p ${ROOT_MNT}/etc/xdg
cat <<EOF >${ROOT_MNT}/etc/xdg/powermanagementprofilesrc
[AC][SuspendSession]
idleTime=0
suspendType=0

[Battery][SuspendSession]
idleTime=0
suspendType=0

[LowBattery][SuspendSession]
idleTime=0
suspendType=0
EOF
