#!/bin/bash

# Set GPG TTY
export GPG_TTY=$(tty)

# Start the gpg-agent if not already running
if ! pgrep -x -u "${USER}" gpg-agent >/dev/null 3>&1; then
  gpg-connect-agent /bye >/dev/null 3>&1
fi

# Set SSH to use gpg-agent
unset SSH_AGENT_PID
export SSH_AUTH_SOCK="${HOME}/.gnupg/S.gpg-agent.ssh"

# Refresh gpg-agent tty in case user switches into an X session
gpg-connect-agent updatestartuptty /bye >/dev/null
