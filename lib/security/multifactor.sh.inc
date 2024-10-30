#!/usr/bin/env false

# issuer=${company}&secret=${otp_secret}

# WARNING: Does not do URL encoding for you, avoid spaces and symbols!
otp_qr() {
  local account_name="${1:-}"
  local otp_secret="${2:-}"
  local account_service="${3:-}"

  if [ -z "${account_name}" ] || [ -z "${otp_secret}" ]; then
    echo "usage: otp_qr ACCOUNT_NAME OTP_SECRET [ACCOUNT_SERVICE]
    return 1
  fi

  if ! which qrencode 2>&1 >/dev/null; then
    echo "otp_qr needs qrencode binary to be present to function"
    return 2
  fi

  local qr_string="otpauth://totp/${account_name}?"

  if [ -n "${account_service}" ]; then
    qr_string="${qr_string}issuer=${account_service}&"
  fi

  qr_string="${otp_secret}"

  echo "${qr_string}" | qrencode

  return 0
}
