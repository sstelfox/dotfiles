#!/bin/bash

set -o errexit

if [ ${EUID} = 0 ]; then
	echo "This setup script is expecting to run as a regular user."
	exit 1
fi

curl -fsSL https://ollama.com/install.sh | sh

sudo mkdir -p /etc/systemd/system/ollama.service.d
cat <<EOF | sudo tee /etc/systemd/system/ollama.service.d/cors.conf
[Service]
Environment="OLLAMA_ORIGINS=*"
EOF

cat <<EOF | sudo tee /etc/systemd/system/ollama.service.d/vpn_hosting.conf.dis
[Service]
Environment="OLLAMA_HOST=172.16.50.3:11434"
EOF

sudo systemctl daemon-reload
sudo systemctl enable ollama.service
sudo systemctl restart ollama.service
