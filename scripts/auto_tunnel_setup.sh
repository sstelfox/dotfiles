#!/bin/bash

set -o errexit
set -o errtrace
set -o pipefail
set -o nounset

function error_handler() {
  echo "Error occurred in $(basename ${BASH_SOURCE[0]}) executing line ${1} with status code ${2}"
}

trap 'error_handler ${LINENO} $?' ERR

# Diagnostic logging when necessary
if [ "${DEBUG:-}" = "true" ]; then
  set -o xtrace
fi

REMOTE_TUNNEL_HOST="wild-spring-cobweb.stelfox.net"
REMOTE_TUNNEL_HOST_PORT="2200"

if [ -f "${HOME}/.dotfiles/system-specific/auto_tunnel.conf" ]; then
  source "${HOME}/.dotfiles/system-specific/auto_tunnel.conf"
fi

mkdir -p "${HOME}/.ssh"
if [ ! -f "${HOME}/.ssh/auto_tunnel_key" ]; then
  echo "Generating Auto Tunnel SSH key..."
  ssh-keygen -t ed25519 -b 521 -N '' -C "autotunnel@$(hostname -f)" -f ${HOME}/.ssh/auto_tunnel_key
fi

chown -R "$(id -un):$(id -gn)" "${HOME}/.ssh"
chmod -R u=rwX,g=,o= "${HOME}/.ssh"

if ! crontab -l 2>&1 | grep -q auto_tunnel.sh; then
  echo "Installing crontab"
  echo "* * * * * ${HOME}/.dotfiles/scripts/auto_tunnel.sh" | crontab
fi

echo 'Attempting to install auto tunnel key on remote host...'

ssh-copy-id -i /home/sstelfox/.ssh/auto_tunnel_key ${REMOTE_TUNNEL_HOST} -p ${REMOTE_TUNNEL_HOST_PORT}

