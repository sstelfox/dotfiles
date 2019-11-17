#!/bin/bash

set -o errexit

if [ ${EUID} != 0 ]; then
  echo "This setup script is expecting to run as root."
  exit 1
fi

dnf remove firewalld -y

dnf install bind-utils git git-email gnupg2-smime graphviz httpd-tools ipset jq mutt \
  nftables nmap pv tcpdump tmux vim-enhanced wireshark-cli -y
dnf remove vim-powerline --noautoremove -y

dnf update -y

systemctl enable sshd.service
systemctl start sshd.service
