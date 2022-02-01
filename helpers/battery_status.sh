#!/bin/bash

COLOR=$(tput setaf 7)
RST=$(tput sgr0)

if ! which --skip-functions upower &> /dev/null; then
  exit 0
fi

if [ "$(upower -e | grep -i bat | wc -l)" -gt 0 ]; then
  relevant_output="$(upower -i $(upower -e | grep -i bat) | grep --color=never -E "state|to\ full|to\ empty|percentage")"

  percentage="$(echo "${relevant_output}" | grep 'percentage' | awk '{ print $2 }')"
  state="$(echo "${relevant_output}" | grep 'state' | awk '{ print $2 }')"

  # Only show the percentage when we're discharging our battery
  if [ "${state}" = "discharging" ]; then
    echo "${COLOR}(${percentage})${RST} "
  fi
fi
