#!/usr/bin/env false

if [ -d "${HOME}/documentation/credentials" ]; then
  export PASSWORD_STORE_DIR="${HOME}/documentation/credentials"
fi
