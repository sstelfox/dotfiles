#!/bin/bash

# Set GPG TTY
export GPG_TTY=$(tty)

# Start the gpg-agent if not already running
gpg-connect-agent /bye >/dev/null 3>&1

# Set SSH to use gpg-agent
unset SSH_AGENT_PID
export SSH_AUTH_SOCK="/run/user/$(id -u)/gnupg/S.gpg-agent.ssh"
