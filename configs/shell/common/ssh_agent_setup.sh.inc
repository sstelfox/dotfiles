#!/usr/bin/env false

# We only want to perform this initialization if we're directly on a system. If we're starting a
# shell from an SSH connection we shouldn't be using a local agent. It should be forwarded if used
# at all.
if [ -z "${SSH_CONNECTION}" ]; then
  # Run our SSH agent initialization when its available
  if ssh_sock="$(_plc active_ssh_agent_socket)"; then
    export SSH_AUTH_SOCK="${ssh_sock}"
  fi
fi
