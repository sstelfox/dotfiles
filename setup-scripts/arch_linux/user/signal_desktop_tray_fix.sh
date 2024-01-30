set -o errexit

if [ ${EUID} = 0 ]; then
	echo "This setup script is expecting to run as a regular user."
	exit 1
fi

# From: https://bugs.archlinux.org/task/79080

mkdir -p $HOME/.local/share/applications

# The archlinux package doesn't include the tray which is really useful, we can fix that by adding
# an appropriate CLI flag to it when it starts up. To accomplish this we need to override the entire
# desktop entry.
cat <<EOF >$HOME/.local/share/applications/signal-desktop.desktop
[Desktop Entry]
Type=Application
Name=Signal
Comment=Signal - Private Messenger
Comment[de]=Signal - Sicherer Messenger
Icon=signal-desktop
Exec=signal-desktop -- --start-in-tray %u
Terminal=false
Categories=Network;InstantMessaging;
StartupWMClass=Signal
MimeType=x-scheme-handler/sgnl;x-scheme-handler/signalcaptcha;
Keywords=sgnl;chat;im;messaging;messenger;sms;security;privat;
X-GNOME-UsesNotifications=true
EOF
