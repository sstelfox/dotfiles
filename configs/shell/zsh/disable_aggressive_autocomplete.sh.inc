#!/usr/bin/env false

# The default behavior for zsh is AWFUL around tab completion. The first file is almost always
# wrong in autocompletion and I don't want to have to backspace or cancel back to where I was at to
# get there. Are people actually insane enough to tab through a list of dozens or hundreds of files
# to get to the right one!?
unsetopt MENU_COMPLETE
unsetopt AUTO_MENU

setopt BASH_AUTO_LIST
