#!/bin/bash

set -o errexit

if [ ${EUID} = 0 ]; then
  echo "this setup script is expecting to run as a regular user." >&2
  exit 1
fi

if ! which npm &>/dev/null;
  echo "requires node to be installed" &>2
  exit 2
fi

npm install -g --prefix=~/.local @google/gemini-cli@latest
