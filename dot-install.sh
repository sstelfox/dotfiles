#!/bin/bash

# This file replaces various dotfiles in the user's home directory
# it makes some assumptions about what's installed such as vim, bash,
# git, bash-completion, rvm, and tmux.
#
# The original files are stored in $HOME/.dotfiles/system-originals/
# if they existed for reference. This folder is not included in the
# repository and as such will not migrate between machines

FILES=( bashrc vim tmux.conf gitconfig )

# This function takes a filename (without the preceding .) and backs
# it up before installing a symbolic link to the repository version
function backup_and_install {
  echo "Installing $1..."

  if [ -f "$HOME/.$1" ]; then
    # If it's a link just delete it
    if [ -h "$HOME/.$1"]; then
      rm -f $HOME/.$1
    else
      mv $HOME/.$1 $HOME/.dotfiles/system-originals/$1
    fi
  fi

  ln -s $HOME/.dotfiles/$1 $HOME/.$1
}

for DOTFILE in FILES; do
  backup_and_install $DOTFILE
done
