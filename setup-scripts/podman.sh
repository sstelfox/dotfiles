#!/bin/bash

set -o errexit

if [ ${EUID} != 0 ]; then
  echo "This setup script is expecting to run as root."
  exit 1
fi

dnf install buildah podman -y

# Note to self: I also rely on a subtle change to the podman network config
# file located at `/etc/cni/net.d/87-podman-bridge.conflist`. Specifically I
# add the following plugin to allow local dns resolution of other pods.
#
# ```
#     {
#       "type": "dnsname",
#       "domainName": "podman.local"
#     },
# ```
