#!/usr/bin/env false

# Run our SSH agent initialization when its available
if ssh_sock="$(_plc active_ssh_agent_socket)"; then
  export SSH_AUTH_SOCK="${ssh_sock}"
fi
