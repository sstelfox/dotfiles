#!/bin/bash

mkdir -p ~/.dotfiles/cinnamon/
dconf dump /org/cinnamon/ > ~/.dotfiles/cinnamon/dconf.settings.bak
