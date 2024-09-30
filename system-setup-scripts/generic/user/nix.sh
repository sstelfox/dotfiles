#!/bin/bash

set -o errexit

if [ ${EUID} = 0 ]; then
  echo "This setup script should only be run in the context of the primary user."
  exit 1
fi

curl -s -o install-nix-2.3.15 https://releases.nixos.org/nix/nix-2.3.15/install
curl -s -o install-nix-2.3.15.asc https://releases.nixos.org/nix/nix-2.3.15/install.asc

curl -s -o nixos.gpg https://nixos.org/edolstra.gpg
gpg2 --import nixos.gpg
gpg2 --verify ./install-nix-2.3.15.asc

chmod +x ./install-nix-2.3.15
./install-nix-2.3.15 --no-daemon

rm -f ./install-nix-2.3.15
