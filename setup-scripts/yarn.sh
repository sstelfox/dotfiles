#!/bin/bash

set -o errexit

if [ ${EUID} != 0 ]; then
  echo "This setup script is expecting to run as root."
  exit 1
fi

curl --silent --location https://dl.yarnpkg.com/rpm/yarn.repo | sudo tee /etc/yum.repos.d/yarn.repo > /dev/null

# Chromium is unfortunately needed for selenium, but I don't always need that...
#dnf install chromedriver chromium -y

dnf install v8 yarn -y
