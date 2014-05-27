#!/bin/bash

function error_handler() {
  echo "$(basename ${BASH_SOURCE[0]}) Error occurred in script at line ${1} with status code ${2}"
  set +o errtrace
}

trap 'error_handler ${LINENO} $?' ERR

set -o errtrace

SSH_ENV="$HOME/.ssh/environment"

function destroy_gnome_interference {
  if [ -n "${GNOME_KEYRING_PID}" ]; then
    if $(kill -0 ${GNOME_KEYRING_PID} &> /dev/null); then
      kill -9 ${GNOME_KEYRING_PID}
    fi
  fi

  unset GNOME_KEYRING_CONTROL SSH_AUTH_SOCK GNOME_KEYRING_PID
}

# start the ssh-agent
function start_agent {
  echo "Initializing new SSH agent..."
  # spawn ssh-agent
  ssh-agent -t 14400 | sed 's/^echo/#echo/' > "$SSH_ENV"
  echo succeeded
  chmod 600 "$SSH_ENV"
  . "$SSH_ENV" > /dev/null
  ssh-add
}

# test for identities
function test_identities {
  # test whether standard identities have been added to the agent already
  ssh-add -l | grep "The agent has no identities" > /dev/null
  if [ $? -eq 0 ]; then
    ssh-add
    # $SSH_AUTH_SOCK broken so we start a new proper agent
    if [ $? -eq 2 ];then
      start_agent
    fi
  fi
}

destroy_gnome_interference

# check for running ssh-agent with proper $SSH_AGENT_PID
if [ -n "$SSH_AGENT_PID" ]; then
  ps -ef | grep "$SSH_AGENT_PID" | grep ssh-agent > /dev/null
  if [ $? -eq 0 ]; then
    test_identities
  fi
# if $SSH_AGENT_PID is not properly set, we might be able to load one from
# $SSH_ENV
else
  if [ -f "$SSH_ENV" ]; then
    . "$SSH_ENV" > /dev/null
  fi
  ps -ef | grep "$SSH_AGENT_PID" | grep -v grep | grep ssh-agent > /dev/null
  if [ $? -eq 0 ]; then
    test_identities
  else
    start_agent
  fi
fi

set +o errtrace
