#!/usr/bin/env sh

set -o errexit
set -o nounset

CONTAINER_NAME="${1}"

nix-build ./nix-definitions/${CONTAINER_NAME}.nix -A exporter
./result/bin/export-${CONTAINER_NAME}
rm -rf result
