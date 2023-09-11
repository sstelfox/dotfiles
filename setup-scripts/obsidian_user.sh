#!/bin/bash

set -o errexit

if [ ${EUID} = 0 ]; then
  echo "This setup script is expecting to run as a regular user."
  exit 1
fi

wget -O ~/.dotfiles/in_path/bin/obsidian https://github.com/obsidianmd/obsidian-releases/releases/download/v1.4.5/Obsidian-1.4.5.AppImage
chmod +x ~/.dotfiles/in_path/bin/obsidian

# TODO: Should give it an icon and I think there are some other
# "required" attributes I should set.
mkdir -p ~/.local/share/applications
cat << 'EOF' > ~/.local/share/applications/obsidian.desktop
[Desktop Entry]
Name=Obsidian
Comment=Obsidian Personal Organizer
Type=Application
Exec=${HOME}/.dotfiles/in_path/bin/obsidian
MimeType=x-scheme-handler/obsidian;
EOF
