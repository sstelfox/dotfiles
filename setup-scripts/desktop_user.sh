#!/bin/bash

set -o errexit

if [ ${EUID} = 0 ]; then
  echo "This setup script is expecting to run as a regular user."
  exit 1
fi

systemctl --user stop ssh-agent.service
systemctl --user disable ssh-agent.service
