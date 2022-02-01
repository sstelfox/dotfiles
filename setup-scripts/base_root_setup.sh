#!/bin/bash

set -o errexit

if [ ${EUID} != 0 ]; then
  echo "This setup script is expecting to run as root."
  exit 1
fi

dnf remove firewalld -y

dnf install bind-utils git graphviz httpd-tools iotop ipset jq mutt pv ranger \
  tcpdump tmux vim-enhanced -y

dnf remove vim-powerline --noautoremove -y

dnf update -y

if [ -n "${SETUP_USER}" ]; then
  usermod -a -G wireshark ${SETUP_USER}
fi

# Rediculous there is no default for maximum log size in journalctl, systemd is such trash software
mkdir -p /etc/systemd/journald.conf.d/
cat << 'EOF' > /etc/systemd/journald.conf.d/00_log_limits.conf
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
systemctl mask systemd-resolved.service

# And clean up the garbage left behind by resolved and forcing NetworkManager
# to generate a valid one.
rm -f /etc/resolv.conf
systemctl restart NetworkManager.service
