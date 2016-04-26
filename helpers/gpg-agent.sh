#!/bin/bash

gpg-agent -q &> /dev/null

if [ "$?" != "0"  ]; then
  gpg-agent --daemon > /dev/null
fi
