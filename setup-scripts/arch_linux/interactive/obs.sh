#!/bin/bash

set -o errexit

if [ ${EUID} = 0 ]; then
	echo "This setup script is expecting to run as a regular user with sudo permissions"
	exit 1
fi

if ! which yay &>/dev/null; then
	echo 'yay needs to be installed to install this AUR package'
	exit 1
fi

sudo pacman -Syu --noconfirm guvcview-qt obs-studio v4l2loopback-dkms

cat <<EOF | tee /etc/modules-load.d/v4l2-loopback.conf >/dev/null
# /etc/modules-load.d/v4l2-loopback.conf
options v4l2loopback devices=2 card_label="VideoLoopbackExclusive,VideoLoopback" exclusive_caps=1,0 video_nr=8,9
EOF

yay -S --norebuild --cleanafter obs-backgroundremoval

# note(sstelfox) Sharing the stream to Firefox may require preloading a
# compatibility library:
#
# ```console
# LD_PRELOAD=/usr/lib/v4l1compat.so firefox
# ```
