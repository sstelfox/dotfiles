#!/usr/bin/env false

err() {
  local msg="${1:-}"
  local data="${2:-}"

  if [ -z "${msg}" ]; then
    _log_fallback "usage: log_err MSG [DATA]"
    exit 229
  fi

  _base_log "ERROR" "${msg}" "${data}"
  return $?
}

fatal() {
  local msg="${1:-}"
  local data="${2:-}"

  if [ -z "${msg}" ]; then
    _log_fallback "usage: log_fatal MSG [DATA]"
    exit 229
  fi

  _base_log "FATAL" "${msg}" "${data}"

  # When a fatal call is triggered we always exit witih the same status code
  exit 230
}

info() {
  local msg="${1:-}"
  local data="${2:-}"

  if [ -z "${msg}" ]; then
    _log_fallback "usage: log_info MSG [DATA]"
    exit 229
  fi

  _base_log "INFO" "${msg}" "${data}"
  return $?
}

warn() {
  local msg="${1:-}"
  local data="${2:-}"

  if [ -z "${msg}" ]; then
    _log_fallback "usage: log_warn MSG [DATA]"
    exit 229
  fi

  _base_log "WARN" "${msg}" "${data}"
  return $?
}

_base_log() {
  local level="${1:-}"
  local msg="${2:-}"
  local data="${3:-}"

  if [ -z "${level}" ] || [ -z "${msg}" ]; then
    _log_fallback "usage: _base_log LEVEL MSG [DATA]"
    exit 229
  fi

  local timestamp
  timestamp="$(date -Iseconds)"

  local trace
  local trace_id
  trace="$(current_trace)"
  trace_id="$(current_trace_id)"

  if [ -n "${data}" ]; then
		# We wrap the provided data in a 'data' field and strip out any empty keys
		data="$(jq -n -c -S --argjson data "${data}" '$data | del(.[] | select(. == null or . == ""))')"
  fi

  jq -c -n -M \
    --arg level "${level}" \
    --arg timestamp "${timestamp}" \
    --arg msg "${msg}" \
    --arg trace_id "${trace_id}" \
    --argjson data "${data:-null}" \
    --argjson trace "${trace}" \
    '{
       level: $level,

       trace: $trace,
       trace_id: $trace_id,

       timestamp: $timestamp,
       msg: $msg
     } + if $data != null then
           {data: ($data | del(.[] | select(. == null or . == "")))}
         else
           {}
         end'
}

_log_fallback() {
  local msg="${1:-}"

  if [ -z "${msg}" ]; then
    echo "usage: log_fallback MSG" >&2
    exit 229
  fi

  echo "${msg}" >&2
}
