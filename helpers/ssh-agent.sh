#!/bin/bash

# Expiration in seconds that the SSH agent will hold on to the keys.
AGENT_TIMEOUT=14400
SSH_ENV="$HOME/.ssh/environment"

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

function ensure_agent_running() {
  if [ -z "$(ps -ef | grep ssh-agent | grep -v grep | awk '{ print $2 }')" ]; then
    # There is no ssh agent running...
    echo 'Starting up an agent'

    # Remove any old environment files that may exist
    if [ -f "${SSH_ENV}" ]; then
      rm -f "${SSH_ENV}"
    fi

    if $(ssh-agent -t ${AGENT_TIMEOUT} | sed 's/^echo/#echo/' > "${SSH_ENV}"); then
      echo "Succeeded"
      chmod 0600 "$SSH_ENV"
    fi
  fi
}

function source_environment() {
  [ -f "${SSH_ENV}" ] && . "${SSH_ENV}"
}

function test_identities() {
  # Test whether standard identities have been added to the agent already
  if $(ssh-add -l | grep "The agent has no identities" &> /dev/null); then
    ssh-add
  fi
}

destroy_gnome_interference
ensure_agent_running
source_environment
test_identities
cleanup

