#!/bin/bash

set -o errexit

if [ ${EUID} = 0 ]; then
	echo "This setup script is expecting to run as a regular user."
	exit 1
fi

PINNED_OBSIDIAN_VERSION="${PINNED_OBSIDIAN_VERSION:-1.5.12}"

if ! which fusermount &>/dev/null; then
	echo 'AppImages like obsidian require fuse to run'
	exit 1
fi

wget -O ~/.dotfiles/in_path/bin/obsidian https://github.com/obsidianmd/obsidian-releases/releases/download/v${PINNED_OBSIDIAN_VERSION}/Obsidian-${PINNED_OBSIDIAN_VERSION}.AppImage
chmod +x ~/.dotfiles/in_path/bin/obsidian

mkdir -p ~/.local/share/applications

cat <<'EOF' >~/.local/share/applications/obsidian.desktop
[Desktop Entry]
Name=Obsidian
Exec=env GDK_BACKEND=x11 ${HOME}/.dotfiles/in_path/bin/obsidian
Icon=~/.dotfiles/assets/obsidian.svg
Comment=Obsidian Personal Organizer
Type=Application
Categories=Utilities
Encoding=UTF-8
MimeType=x-scheme-handler/obsidian;
EOF
