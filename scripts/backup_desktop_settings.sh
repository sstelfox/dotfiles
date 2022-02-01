#!/bin/bash

set -o errexit

mkdir -p ~/.dotfiles/cinnamon/
dconf dump / > ~/.dotfiles/cinnamon/dconf.settings.bak
