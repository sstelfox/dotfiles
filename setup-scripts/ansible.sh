#!/bin/bash

set -o errexit

if [ ${EUID} = 0 ]; then
  echo "This setup script should only be run in the context of the primary user."
  exit 1
fi

dnf install ansible -y
