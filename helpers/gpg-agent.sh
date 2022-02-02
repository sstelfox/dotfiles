#!/bin/bash

# Only attempt to setup the gpg-agent if we're not on an SSH connection
if [ -z "${SSH_CONNECTION}" ]; then
  unset SSH_AGENT_PID

  if [ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]; then
    export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
  fi

  export GPG_TTY=$(tty)
  gpg-connect-agent updatestartuptty /bye >/dev/null 3>&1
fi
