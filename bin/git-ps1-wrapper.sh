#!/bin/bash

GIT_PROMPT_LOC="/usr/share/git-core/contrib/completion/git-prompt.sh"

if [ -f $GIT_PROMPT_LOC ]; then
  source $GIT_PROMPT_LOC
  __git_ps1
fi

# Arch Linux stores this in a different location
ALT_PROMPT_LOC="/usr/share/git/completion/git-prompt.sh"

if [ -f $ALT_PROMPT_LOC ]; then
  source $ALT_PROMPT_LOC
  __git_ps1
fi
