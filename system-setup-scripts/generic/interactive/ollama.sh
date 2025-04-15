#!/bin/bash

set -o errexit

if [ ${EUID} = 0 ]; then
  echo "This setup script is expecting to run as a regular user."
  exit 1
fi

#curl -fsSL https://ollama.com/install.sh | sh
pacman -Sy ollama-cuda

# Add to fstab:
# /var/run/media/sstelfox/TLPRed-TS+/language_models/ollama /var/lib/ollama/.ollama     none     defaults,bind,noauto     0 0
# mount /var/lib/ollama/.ollama before starting

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
# Don't autostart, need to manually mount... Could have systemd handle it but *shrug*
#sudo systemctl enable ollama.service
sudo systemctl restart ollama.service
