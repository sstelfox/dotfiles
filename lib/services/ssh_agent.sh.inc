#!/usr/bin/env false

# Expiration in seconds that the SSH agent will hold on to the keys. We'll default this to 30
# minutes as a nice balance between convenience and security.
AGENT_TIMEOUT=1800

active_ssh_agent_socket() {
  # Check for an existing and function auth sock
  case "${SSH_AUTH_SOCK:-}" in
    # If its the trash one Gnome provides that gets automatically turned back on we ignore that
    /run/user/*/gcr/ssh) : ;;
    # Nothing set...
    "") : ;;
    # Anything else we should test and see if it works
    *)
      if test_ssh_agent_socket "${SSH_AUTH_SOCK}"; then
        echo "${SSH_AUTH_SOCK}"
        return 0
      fi
      ;;
  esac

  # If there is no agent in the environment, search /tmp for possible agents to reuse before
  # starting a fresh ssh-agent process.
  for agent_socket in $(find_ssh_agent_sockets); do
    if test_ssh_agent_socket "${agent_socket}"; then
      echo "${agent_socket}"
      return 0
    fi
  done

  # If at this point we still haven't located an agent, it's time to start a new one
  eval "$(ssh-agent -t "${AGENT_TIMEOUT}" 2>/dev/null)"

  if [ -z "${SSH_AUTH_SOCK}" ]; then
    echo "failed to locate or initialize ssh agent socket" >&2
    return 1
  fi

  echo "${SSH_AUTH_SOCK}"
}

find_ssh_agent_sockets() {
  # /var/tmp is primarily for MacOS, /tmp for the Linux world
  find /var/tmp /tmp -uid "$(id -u)" -type s -name "agent.*" 2>/dev/null || return 1
}

test_ssh_agent_socket() {
  socket_path="${1:-}"
  if [ -z "${socket_path}" ]; then
    echo "usage: ssh_agent_testsocket SOCKET_PATH" >&2
    return 1
  fi

  ssh_add_bin="$(posix_which ssh-add)"
  if [ ! -x "${ssh_add_bin}" ]; then
    echo "ssh-add is not available; agent testing aborted" >&2
    return 2
  fi

  if [ ! -e "${socket_path}" ]; then
    # This happens when the agent has timed out and closed down but the socket is still referenced
    # in the environment. Fairly common might make a good debug message but I don't want to see it
    # every time this occurs
    return 3
  fi

  if [ -S "${socket_path}" ]; then
    SSH_AUTH_SOCK="${socket_path}" ${ssh_add_bin} -l >/dev/null

    if [ "$?" -eq 2 ]; then
      echo "socket at '${socket_path}' is dead! deleting..." >&2
      rm -f "${socket_path}"
      return 4
    fi

    return 0
  else
    echo "socket provided to ssh_agent_testsocket at '${socket_path}' is not a socket!" >&2
    return 5
  fi
}
