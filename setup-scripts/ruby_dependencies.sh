#!/bin/bash

set -o errexit

if [ ${EUID} != 0 ]; then
  echo "This setup script is expecting to run as root."
  exit 1
fi

#dnf install patch autoconf automake bison fftw-devel gcc-c++ libcurl-devel libffi-devel \
#  libtool libyaml-devel openssl-devel patch postgresql postgresql-devel readline-devel \
#  sqlite-devel zlib-devel -y

# Note: some tests and environments I have require the redis client which is
# available in the redis package.

dnf install autoconf automake bison gcc-c++ libffi-devel libpq-devel libstdc++-static libtool \
  libyaml-devel patch readline-devel sqlite-devel zlib-devel -y
