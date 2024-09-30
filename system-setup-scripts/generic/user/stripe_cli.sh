#!/bin/bash

set -o errexit

if [ ${EUID} = 0 ]; then
	echo "This setup script is expecting to run as a regular user."
	exit 1
fi

wget -O /tmp/stripe.tar.gz https://github.com/stripe/stripe-cli/releases/download/v1.19.1/stripe_1.19.1_linux_x86_64.tar.gz
tar -xf /tmp/stripe.tar.gz -C $HOME/.dotfiles/in_path/bin stripe
rm -f /tmp/stripe.tar.gz
