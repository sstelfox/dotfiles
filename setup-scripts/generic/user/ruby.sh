#!/bin/bash

set -o errexit

if [ ${EUID} = 0 ]; then
	echo "This setup script is expecting to run as a regular user."
	exit 1
fi

# RVM gpg key
gpg2 --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys \
	409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
curl -sSL https://get.rvm.io | bash -s -- --ignore-dotfiles stable

# Re-source our bash profile so we can use RVM
source /home/sstelfox/.rvm/scripts/rvm

rvm install 3.2.2 --no-docs
rvm gemset create global

rvm use ruby-3.2.2@global --default
rvm gemset use global --default

# Install the globally available gems
gem install -r pry rotp ruby-lsp --no-document

mkdir -p ~/workspace/ruby
