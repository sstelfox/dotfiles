#!/usr/bin/env false

clear_trace() {
  unset __SHELL_TRACE __SHELL_TRACE_ID
}

current_trace() {
  if ! trace_enabled; then
    echo "[]"
  fi

  if [ -z "${__SHELL_TRACE:-}" ]; then
    fatal "trace requested without initialization"
  fi

  echo "${__SHELL_TRACE}"
}

current_trace_id() {
  if ! trace_enabled; then
    return 1
  fi

  if [ -z "${__SHELL_TRACE_ID:-}" ]; then
    fatal "trace requested without initialization"
  fi

  echo "${__SHELL_TRACE_ID}"
}

trace_enabled() {
  # tracing relies on the availability of jq
  which jq >/dev/null 2>&1 || return 1

  [ -n "${__SHELL_TRACE_ID:-}" ] && return 0
  return 2
}

trace_init() {
  if [ -z "${__SHELL_TRACE_ID:-}" ]; then
    # Currently broken... :'(
    #export __SHELL_TRACE_ID="$(tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c 16)"
    export __SHELL_TRACE_ID="{random-trace-id}"
    export __SHELL_TRACE="[]"

    push_trace
  fi
}

pop_trace() {
  if ! trace_enabled; then
    return 0
  fi

  if [ -z "${__SHELL_TRACE:-}" ]; then
    fatal "trace requested without initialization"
  fi

  if [ "${__SHELL_TRACE}" = "[]" ]; then
    return 0
  fi

  export __SHELL_TRACE="$(echo "${__SHELL_TRACE}" | jq 'del(.[-1])')"

  return 0
}

push_trace() {
  if ! trace_enabled; then
    return 0
  fi

  if [ -z "${__SHELL_TRACE:-}" ]; then
    fatal "trace requested without initialization"
  fi

  local new_trace
  new_trace="$(basename -s .inc -- "${0}")"
  new_trace="$(basename -s .sh -- "${new_trace}")"

  export __SHELL_TRACE="$(echo "${__SHELL_TRACE}" | jq --arg new "${new_trace}" '. + [$new]')"
}
