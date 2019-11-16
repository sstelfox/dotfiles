#!/bin/bash

source _root_prelude.sh

dnf install patch autoconf automake bison fftw-devel gcc-c++ libcurl-devel libffi-devel \
  libtool libyaml-devel openssl-devel patch postgresql-devel readline-devel sqlite-devel \
  zlib-devel -y
