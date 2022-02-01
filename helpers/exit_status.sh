#!/bin/bash

GOOD=$(echo -e '\xE2\x9C\x93')
#GOOD="+"
BAD="-"

if [ "$1" -eq "0" ]; then
  echo $GOOD
else
  echo $BAD
fi
