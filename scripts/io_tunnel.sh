#!/bin/bash

HOST_IP=$(/usr/bin/dig +nocmd +noall +answer io.stelfox.net | awk '{ print $5 }')
if [ -z "${HOST_IP}" ]; then
  # Unable to resolve the shell host, bail out
  exit 0
fi

if /usr/sbin/ss -nt | grep ESTAB | grep -q ${HOST_IP}:2200; then
  # Shell already appears to be established, bail out
  exit 0
fi

ssh io -fi ~/.ssh/auto_io_tunnel_rsa -R 127.0.0.1:4320:127.0.0.1:22 -o ExitOnForwardFailure=yes -N
