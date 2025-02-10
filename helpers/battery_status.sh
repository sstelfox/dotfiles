#!/bin/bash

if ! _plc posix_which upower >/dev/null 2>&1; then
  exit 0
fi

battery_count="$(upower -e | grep -c bat 2>/dev/null)"

if [ "${battery_count}" -gt 0 ]; then
  primary_battery="$(upower -e | grep -i bat | head -n 1 2>/dev/null)"

  if [ -z "${primary_battery}" ]; then
    exit 1
  fi

  relevant_output="$(upower -i "${primary_battery}" | grep --color=never -E "state|to\ full|to\ empty|percentage")"

  percentage="$(echo "${relevant_output}" | grep percentage | awk '{ print $2 }')"
  state="$(echo "${relevant_output}" | grep state | awk '{ print $2 }')"

  # Only show the percentage when we're discharging our battery
  if [ "${state}" = "discharging" ]; then
    echo "(${percentage}) "
  fi
fi
