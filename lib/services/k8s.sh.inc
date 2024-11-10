#!/bin/sh

# Check if a TCP port is currently listening using passive checks only
check_tcp_port_listening() {
  local port="$1"

  if command -v ss >/dev/null 2>&1; then
    if ss -tln "sport = :${port}" 2>/dev/null | grep -q LISTEN; then
      return 0
    fi

    return 1
  fi

  if command -v netstat >/dev/null 2>&1; then
    # -t for TCP only, -n for numeric ports, -l for listening only (BSD style)
    # Some systems need -a instead of -l, so we include both patterns
    if netstat -tnla 2>/dev/null | grep -q "^tcp.*\.${port}[[:space:]]*[*.][*.][[:space:]]*LISTEN\|^tcp.*:${port}[[:space:]]*.*LISTEN"; then
      return 0
    fi

    return 1
  fi

  echo "Error: Neither 'ss' nor 'netstat' found. One is required for TCP port checking." >&2
  return 2
}

# Wait for a TCP port to become listening, up to a timeout
wait_tcp_port_listening() {
  local port="${1:-}"

  if [ -z "${port}" ]; then
    echo "usage: wait_tcp_port_listening PORT" >&2
    return 1
  fi

	# Shooting for a maximum of 3 seconds to wait for the port to become available. These clusters
  # SHOULD be able to handle these connection setups in less than half a second generally.
  local max_attempts=30
  local attempt=1

  while [ $attempt -le $max_attempts ]; do
    if check_tcp_port_listening "${port}"; then
      return 0
    fi

    if sleep 0.1 2>/dev/null; then
      attempt=$((attempt + 1))
    elif sleep 1 2>/dev/null; then
      # We can't do as many checks with less granularity, but we don't want to suddenly wait for 30
      # seconds on some systems accidentally...
      attempt=$((attempt + 10))
    else
      echo "error: failed to sleep while waiting for port to become available" >&2
      return 3
    fi

  done

  return 2
}

# This is a useful little wrapper allowing us to start-up a port-forward connection to a specific
# single service in the background so we can utilize it with the command. Does basic sanity checks
# and ensures the port is available before proceeding.
cmd_with_k8s_port_forward() {
  namespace="$1"
  service="$2"
  ports="$3"

  shift 3

  if [ -z "${namespace}" ] || [ -z "${service}" ] || [ -z "${ports}" ] || [ $# -eq 0 ]; then
    echo "usage: cmd_with_k8s_port_forward NAMESPACE SERVICE LOCAL:REMOTE_PORT COMMAND [ARGS...]" >&2
    return 1
  fi

  if ! kubectl get namespace "${namespace}" >/dev/null 2>&1; then
    echo "error: namespace '${namespace}' does not exist\n" >&2
    return 2
  fi

  if ! kubectl -n "${namespace}" get service "${service}" >/dev/null 2>&1; then
    echo "error: service '${service}' not found in namespace '${namespace}'" >&2
    return 3
  fi

  # extract local port from the ports argument
  local_port="${ports%%:*}"

  kubectl port-forward -n "${namespace}" "service/${service}" "${ports}" >/dev/null 2>&1 &
  port_forward_pid=$!

  if ! kill -0 "${port_forward_pid}" >/dev/null 2>&1; then
    echo "Error: Port-forward failed to start" >&2
    return 4
  fi

  if ! wait_tcp_port_listening "${local_port}"; then
    echo "error: TCP port ${local_port} did not start listening within timeout" >&2

    kill "${port_forward_pid}" >/dev/null 2>&1 || true
    wait "${port_forward_pid}" 2>/dev/null || true

    return 5
  fi

  eval "$@"
  return_code=$?

  kill "${port_forward_pid}" >/dev/null 2>&1 || true
  wait "${port_forward_pid}" 2>/dev/null || true

  return "${return_code}"
}
