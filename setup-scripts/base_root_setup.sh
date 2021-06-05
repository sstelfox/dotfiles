#!/bin/bash

set -o errexit

if [ ${EUID} != 0 ]; then
  echo "This setup script is expecting to run as root."
  exit 1
fi

dnf remove firewalld -y

dnf install bind-utils git git-email git-lfs gnupg2-smime graphviz httpd-tools iotop ipset jq mutt \
  nftables nmap pv ranger tcpdump tmux vim-enhanced wireshark-cli -y

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
