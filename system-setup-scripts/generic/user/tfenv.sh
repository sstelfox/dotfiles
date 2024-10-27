#!/bin/bash

set -o errexit

if [ ${EUID} = 0 ]; then
	echo "This setup script is expecting to run as a regular user."
	exit 1
fi

git clone --depth=1 https://github.com/tfutils/tfenv.git ~/.tfenv
