#!/bin/bash

if [ -n "${1}" ]; then
  echo "usage: $0 EXIT_CODE"
  exit 1
fi

if [ "${1}" -eq "0" ]; then
  printf '\xE2\x9C\x93'
else
  printf '-'
fi
