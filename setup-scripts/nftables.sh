#!/bin/bash

set -o errexit

if [ ${EUID} != 0 ]; then
  echo "This setup script is expecting to run as root."
  exit 1
fi

cat << 'EOF' > /etc/sysconfig/nftables.conf
flush ruleset

table inet filter {
  chain input {
    type filter hook input priority 0; policy drop;

    ct state invalid drop
    ct state established,related accept
    iif "lo" accept

    ip protocol icmp accept
    ip6 nexthdr icmpv6 accept

    tcp dport 22 accept

    ip protocol tcp tcp dport 67 tcp sport 68 accept

    counter
  }

  chain forward {
    # Accept is needed here as docker doesn't know how to modify nft rulesets... thank god
    type filter hook forward priority 0; policy accept;
  }

  chain output {
    type filter hook output priority 0; policy drop;

    ct state established,related accept
    oif "lo" accept

    ip protocol icmp accept
    ip6 nexthdr icmpv6 accept

    # Allow all outbound traffic to local v4 networks
    #ip daddr 192.168.0.0/16 accept
    #ip daddr 172.16.0.0/12 accept
    #ip daddr 10.0.0.0/8 accept

    # DHCPv4
    tcp dport 67 tcp sport 68 accept

    # SSH, DNS, HTTP, HTTPS, git, my SSH alt port, and GPG keyserver port
    tcp dport { 22, 53, 80, 443, 873, 2200, 11371 } accept
    # DNS and NTP
    udp dport { 53, 123 } accept

    ct state new log level warn prefix "egress attempt: "
    counter reject with icmp type admin-prohibited
  }
}
EOF

sudo systemctl enable nftables.service
sudo systemctl start nftables.service
