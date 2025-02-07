#!/usr/bin/env false

is_privileged() {
  uid=$(id -u) || return 1
  [ "${uid}" = 0 ]
}
