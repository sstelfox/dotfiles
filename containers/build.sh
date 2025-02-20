#!/usr/bin/env sh

set -o errexit
set -o nounset
set -o pipefail

CONTAINER_NAME="${1:-vnix-pure}"

BASE_NIX_VERSION="23.11"
BASE_NIX_HASH="1f5d2g1p6nfwycpmrnnmc2xmcszp804adp16knjvdkj8nz36y1fg"

if [ "${VIRTUAL_NIX_ENV:-}" = "true" ] || which nix-build >/dev/null 2>&1; then
  nix-build ./nix-definitions/"${CONTAINER_NAME}".nix \
    --arg nixVersion "\"${BASE_NIX_VERSION}\"" --arg nixHash "\"${BASE_NIX_HASH}\"" \
    -A exporter

  # Run the built in exporter script
  ./result/bin/export-"${CONTAINER_NAME}"

  # Clean-up the leftovers
  rm -rf result
else
  vnix $0 $@
fi
