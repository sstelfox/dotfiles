#!/bin/bash

# Only attempt to setup the gpg-agent if we're not on an SSH connection
if [ -z "${SSH_CONNECTION}" ]; then
  unset SSH_AGENT_PID
  # shellcheck disable=SC2155
  export GPG_TTY="$(tty)"
  gpg-connect-agent updatestartuptty /bye >/dev/null >/dev/null 2>&1
fi

if [ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]; then
  # shellcheck disable=SC2155
  export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket 2>/dev/null)"
fi
