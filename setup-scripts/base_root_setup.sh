#!/bin/bash

set -o errexit

if [ ${EUID} != 0 ]; then
	echo "This setup script is expecting to run as root."
	exit 1
fi

dnf install bind-utils fd-find git git-crypt graphviz httpd-tools iotop ipset \
	jq neovim pv python3-neovim ripgrep tcpdump tmux vim-enhanced -y

dnf update -y

# Rediculous there is no default for maximum log size in journalctl, systemd is such trash software
mkdir -p /etc/systemd/journald.conf.d/
cat <<'EOF' >/etc/systemd/journald.conf.d/00_log_limits.conf
[Journal]
RateLimitBurst=5000
RateLimitIntervalSec=30s
RuntimeMaxUse=200M
SystemMaxUse=200M
EOF

systemctl enable sshd.service
systemctl start sshd.service

# Resolved is unreliable and has broken DNS on my system many times. Fuck this service
systemctl disable systemd-resolved.service
systemctl stop systemd-resolved.service

# Unfortunately some updates from Fedora have automatically re-enabled this
# service. Mask it so attempts to turn this back on fail.
if systemctl mask systemd-resolved.service &>/dev/null; then
	# And clean up the garbage left behind by resolved, force NetworkManager to
	# generate a valid one.
	rm -f /etc/resolv.conf
	systemctl restart NetworkManager.service

	# Give it a few seconds to fix itself, poor dumb thing
	sleep 30
fi
