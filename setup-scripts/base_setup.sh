#!/bin/bash

source _root_prelude.sh

dnf remove firewalld -y

dnf install bind-utils git git-email gnupg2-smime graphviz httpd-tools ipset jq mutt \
  nftables nmap pv tcpdump tmux vim-enhanced wireshark-cli -y
dnf remove vim-powerline --noautoremove -y

systemctl enable sshd.service
systemctl start sshd.service
