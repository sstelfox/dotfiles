#!/bin/bash

set -o errexit

if [ ${EUID} = 0 ]; then
	echo "This setup script is expecting to run as a regular user."
	exit 1
fi

curl -fsSL https://ollama.com/install.sh | sh

cat <<EOF | sudo tee /etc/systemd/system/ollama.service.d/cors.conf
[Service]
Environment="OLLAMA_ORIGINS=*"
EOF

sudo systemctl daemon-reload
sudo systemctl enable ollama.service
sudo systemctl restart ollama.service
