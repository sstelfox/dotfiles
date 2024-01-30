#!/bin/bash

set -o errexit

if [ ${EUID} != 0 ]; then
  echo "This setup script is expecting to run as root."
  exit 1
fi

curl --silent --location https://dl.yarnpkg.com/rpm/yarn.repo | sudo tee /etc/yum.repos.d/yarn.repo > /dev/null

# Chromium is unfortunately needed for selenium
dnf install chromedriver chromium v8 yarn -y
