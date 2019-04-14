#!/bin/bash

if [ ! -f ~/.dotfiles/cinnamon/dconf.settings.bak ]; then
  echo "No settings backup found"
  exit 1
fi

dconf reset -f /org/cinnamon/
dconf load /org/cinnamon/ < ~/.dotfiles/cinnamon/dconf.settings.bak

echo "You likely need to log out and back in..."
