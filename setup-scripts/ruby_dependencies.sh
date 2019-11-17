#!/bin/bash

set -o errexit

if [ ${EUID} != 0 ]; then
  echo "This setup script is expecting to run as root."
  exit 1
fi

dnf install patch autoconf automake bison fftw-devel gcc-c++ libcurl-devel libffi-devel \
  libtool libyaml-devel openssl-devel patch postgresql-devel readline-devel sqlite-devel \
  zlib-devel -y
