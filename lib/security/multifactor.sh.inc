#!/usr/bin/env false

# otpauth://totp/${account_name}?issuer=${company}&secret=${otp_secret}

otp_qr() {
  local account_name="${1:-}"
  local otp_secret="${2:-}"
  local account_service="${3:-}"

  if [ -z "${account_name}" ] || [ -z "${otp_secret}" ]; then
    echo "usage: otp_qr ACCOUNT_NAME OTP_SECRET [ACCOUNT_SERVICE]
    return 1
  fi

  local qr_string=""

  return 0
}
