#!/bin/bash

set -o errexit

if [ ${EUID} = 0 ]; then
	echo "This setup script is expecting to run as a regular user with sudo permissions"
	exit 1
fi

SERVER_HOST="hollow-twilight-ocean.stelfox.net"
DNS_SERVER="1.1.1.1"
SERVER_PUBLIC_KEY="y7xbT5mr9B8r97Lx+yRJEwBwCSsbalvgAWTOIuHM9AU="

SERVER_PUBLIC_KEY="y7xbT5mr9B8r97Lx+yRJEwBwCSsbalvgAWTOIuHM9AU="
SERVER_PUBLIC_IPV4_ENDPOINT="$(dig +short -t A ${SERVER_HOST} @${DNS_SERVER})"
SERVER_PUBLIC_IPV6_ENDPOINT="$(dig +short -t AAAA ${SERVER_HOST} @${DNS_SERVER})"

if [ -z "${SERVER_PUBLIC_IPV4_ENDPOINT}" -a -z "${SERVER_PUBLIC_IPV6_ENDPOINT}" ]; then
	echo "Unable to resolve either VPN server endpoints"
	exit 1
fi

# Needs to be set per host
VPN_LOCAL_IPv4_ADDR=""
VPN_LOCAL_IPV6_ADDR=""

VPN_IPV4_NET=""
VPN_IPV6_NET=""

if [ -z "${VPN_LOCAL_IPv4_ADDR}" -o -z "${VPN_LOCAL_IPV6_ADDR}" ]; then
	echo "Local IP addresses need to be set in the script"
	exit 1
fi

if [ -z "${VPN_IPv4_NET}" -o -z "${VPN_IPV6_NET}" ]; then
	echo "VPN networks need to be set in the script"
	exit 1
fi

wg genkey | tee /etc/wireguard/client.private | wg pubkey >/etc/wireguard/client.public
wg genpsk >/etc/wireguard/client.psk

PRESHARED_KEY="$(cat /etc/wireguard/client.psk)"
PRIVATE_KEY="$(cat /etc/wireguard/client.private)"
PUBLIC_KEY="$(cat /etc/wireguard/client.public)"

cat <<EOF >/etc/wireguard/wg0.conf
[Interface]
Address = ${VPN_LOCAL_IPv4_ADDR}, ${VPN_LOCAL_IPV6_ADDR}
PrivateKey = "${PRIVATE_KEY}"

[Peer]
PublicKey = ${SERVER_PUBLIC_KEY}
PresharedKey = "${PRESHARED_KEY}"

AllowedIPs = ${VPN_IPV4_NET}, ${VPN_IPV6_NET}
Endpoint = ${SERVER_PUBLIC_IPV4_ENDPOINT}:51820
#Endpoint = ${SERVER_PUBLIC_IPV6_ENDPOINT}:51820
PersistentKeepalive = 25
EOF

systemctl enable wg-quick@wg0.service
systemctl start wg-quick@wg0.service

# Convert the host host/net syntax to host/host to allow the individual
# machines rather than the entire network.
VPN_LOCAL_IPV4_HOST="$(echo ${VPN_LOCAL_IPv4_ADDR} | cut -d/ -f1)/32"
VPN_LOCAL_IPV6_HOST="$(echo ${VPN_LOCAL_IPv6_ADDR} | cut -d/ -f1)/128"

cat <<EOF
You will need to provide the server with the following configuration and restart the server:

[Peer]
PublicKey = ${PUBLIC_KEY}
PresharedKey = "${PRESHARED_KEY}"
AllowedIPs = ${VPN_LOCAL_IPv4_HOST}, ${VPN_LOCAL_IPV6_HOST}
EOF
