#!/bin/bash

set -o errexit

if [ ${EUID} != 0 ]; then
  echo "This setup script is expecting to run as root."
  exit 1
fi

wget -O /tmp/slack.rpm https://downloads.slack-edge.com/releases/linux/4.29.149/prod/x64/slack-4.29.149-0.1.el8.x86_64.rpm
dnf install /tmp/slack.rpm -y
rm -f /tmp/slack.rpm
