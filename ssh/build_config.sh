#!/bin/bash

set -o errexit
set -o errtrace
set -o pipefail
set -o noclobber
set -o nounset

DOTFILE_DIR="$HOME/.dotfiles"

# Generate our SSH config
truncate -s 0 ${DOTFILE_DIR}/ssh/config

for cfg_segment in $(ls $DOTFILE_DIR/ssh/shared-config/* 2>/dev/null | sort); do
  cat ${cfg_segment} >> ${DOTFILE_DIR}/ssh/config
  echo >> ${DOTFILE_DIR}/ssh/config
done

for cfg_segment in $(ls $DOTFILE_DIR/ssh/system-config/* 2>/dev/null | sort); do
  cat ${cfg_segment} >> ${DOTFILE_DIR}/ssh/config
  echo >> ${DOTFILE_DIR}/ssh/config
done

# Ensure our permissions are good
chmod -R u=rwX,g=,o= ${DOTFILE_DIR}
chmod -R u=rwX,g=,o= ${DOTFILE_DIR}/ssh
