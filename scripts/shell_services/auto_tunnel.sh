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

unset SSH_AUTH_SOCK

REMOTE_TUNNEL_USER="receiver"
REMOTE_TUNNEL_HOST="singing-evening-road.stelfox.net"
REMOTE_TUNNEL_LOOPBACK_PORT="4319"

if [ -f "${HOME}/.dotfiles/system-specific/auto_tunnel.conf" ]; then
  source "${HOME}/.dotfiles/system-specific/auto_tunnel.conf"
fi

HOST_IP=$(/usr/bin/dig +nocmd +noall +answer ${REMOTE_TUNNEL_HOST} | awk '{ print $5 }')
if [ -z "${HOST_IP}" ]; then
  # Unable to resolve the shell host, bail out
  exit 0
fi

if /usr/sbin/ss -nt | grep ESTAB | grep -q ${HOST_IP}:${REMOTE_TUNNEL_HOST_PORT:-2200}; then
  # Shell very well could be established... Lets double check using process
  # inspection to double check...
  if ps aux | grep "127.0.0.1:${REMOTE_TUNNEL_LOOPBACK_PORT}:127.0.0.1:22" | grep -vq grep; then
    # Yep it's actually running...
    exit 0
  fi
fi

ssh ${REMOTE_TUNNEL_USER}@${REMOTE_TUNNEL_HOST} \
  -fi /home/sstelfox/.ssh/auto_tunnel_key \
  -R 127.0.0.1:${REMOTE_TUNNEL_LOOPBACK_PORT}:127.0.0.1:22 \
  -o ExitOnForwardFailure=yes -N
