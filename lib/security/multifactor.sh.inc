#!/usr/bin/env false

# WARNING: Does not do URL encoding for you, avoid spaces and symbols!
otp_qr() {
  local account_name="${1:-}"
  local otp_secret="${2:-}"
  local account_service="${3:-}"

  if [ -z "${account_name}" ] || [ -z "${otp_secret}" ]; then
    echo "usage: otp_qr ACCOUNT_NAME OTP_SECRET [ACCOUNT_SERVICE]"
    return 1
  fi

  if ! posix_which qrencode >/dev/null; then
    echo "otp_qr needs qrencode binary to be present to function"
    return 2
  fi

  local qr_string="otpauth://totp/${account_name}?"

  if [ -n "${account_service}" ]; then
    qr_string="${qr_string}issuer=${account_service}&"
  fi

  qr_string="${qr_string}secret=${otp_secret}"

  echo "${qr_string}" | qrencode -t ANSI256

  return 0
}
