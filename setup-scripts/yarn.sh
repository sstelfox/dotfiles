#!/bin/bash

source _root_prelude.sh

curl --silent --location https://dl.yarnpkg.com/rpm/yarn.repo | sudo tee /etc/yum.repos.d/yarn.repo
dnf install v8 yarn -y
