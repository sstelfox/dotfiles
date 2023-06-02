#!/bin/bash

set -o errexit

if [ ${EUID} != 0 ]; then
	echo "This setup script is expecting to run as root."
	exit 1
fi

dnf install clang cmake perl-FindBin openssl sccache -y
