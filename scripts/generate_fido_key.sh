#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

VERSION="v0.7.3"

OPTIONS=f:v
LONGOPTS=file:,version

! PARSED=$(getopt --options=${OPTIONS} --longoptions=${LONGOPTS} --name "$0" -- "$@")
if [ ${PIPESTATUS[0]} -ne 0 ]; then
  exit 1
fi

eval set -- "$PARSED"

file=

while true; do
  case "$1" in
    -f|--file)
      file="$2"
      shift 2
      ;;
    -v|--version)
      echo "FIDO Key Generator ${VERSION}"
      exit 0
      ;;
    --)
      # No remaining arguments left...
      shift
      break
      ;;
    *)
      echo $1
      echo "Bad arguments passed to FIDO generator"
      exit 2
      ;;
  esac
done

# TODO: validate I received decent inputs, edit comment via param, whether it has a password or not

ssh-keygen -t ecdsa-sk -f ${file} -C "Test Key"
