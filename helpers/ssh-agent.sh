#!/bin/bash

# Expiration in seconds that the SSH agent will hold on to the keys.
AGENT_TIMEOUT=14400
SSH_ENV="$HOME/.ssh/environment"

# If the environment file exists, source it. If it's not accurate it'll be
# dealt with later.
if [ -f "${SSH_ENV}" ]; then
  . ${SSH_ENV}
fi

# Remove the error tracing and unset our trap.
function cleanup() {
  set +o errtrace
  trap - ERR
}

# A simple error handler that allows us to trace back any issues encountered
# within a script back too their source.
function error_handler() {
  echo
  echo "$(basename ${1}) Error occurred in script at line ${2} with status code ${3}"
  echo "Relevant line was: $(sed -n ${2}p ${1})"

  # Only one error can occur in a script before it exits, so be sure we
  # cleanup after ourselves.
  cleanup
}

# Setup the error handler as early as possible
trap 'error_handler "${BASH_SOURCE[0]}" ${LINENO} $?' ERR
set -o errtrace

# Return whether or not there is a valid agent running
function check_agent_status() {
  if $(ps h ${SSH_AGENT_PID}); then
    # Agent's PID still seems active... Can we check the status of our keys?
    if $(ssh-add -l &> /dev/null); then
      # We still have an active agent connection
      return 0
    fi
  fi

  if [ -n "${SSH_AUTH_SOCK}" ]; then
    rm -f ${SSH_AUTH_SOCK}
  fi

  unset SSH_AGENT_PID SSH_AUTH_SOCK
  return 1
}

# Gnome is a damn evil bastard, it tries wants control over SSH agent's but
# I'll have none of that.
function destroy_gnome_interference() {
  if [ -n "${GNOME_KEYRING_PID}" ]; then
    echo -n "Detected Gnome's keyring... "
    if $(ps h ${GNOME_KEYRING_PID}); then
      echo -n "And it's active... "
      kill -9 ${GNOME_KEYRING_PID}
      echo "Now it's not."
    else
      echo "But it's dead..."
    fi
  fi

  unset GNOME_KEYRING_CONTROL GNOME_KEYRING_PID SSH_ASKPASS
}

# start the ssh-agent
function start_agent {
  echo "Initializing new SSH agent..."
  # spawn ssh-agent
  if $(ssh-agent -t 14400 | sed 's/^echo/#echo/' > "${SSH_ENV}"); then
    echo "Succeeded"
    chmod 0600 "$SSH_ENV"
    . "$SSH_ENV" > /dev/null
    ssh-add
  fi
}

function test_identities {
  # Test whether standard identities have been added to the agent already
  if $(ssh-add -l | grep "The agent has no identities" > /dev/null); then
    ssh-add
  fi
}

destroy_gnome_interference

# If no agent...
if check_agent_status; then
  echo "Agent seems good..."
else
  echo "Need too startup the agent..."
  start_agent
fi

test_identities

# Once the script has exited we need to ensure we cleanup our changed settings.
cleanup

