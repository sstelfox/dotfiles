#!/bin/bash

GIT_PROMPT_LOC="/usr/share/git-core/contrib/completion/git-prompt.sh"

if [ -f $GIT_PROMPT_LOC ]; then
  source $GIT_PROMPT_LOC
  __git_ps1
fi
