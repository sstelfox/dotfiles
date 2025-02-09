#!/bin/bash

GIT_PROMPT_LOCATION=""

if [ -f "/usr/share/git-core/contrib/completion/git-prompt.sh" ]; then
  # Fedora location
  GIT_PROMPT_LOCATION="/usr/share/git-core/contrib/completion/git-prompt.sh"
elif [ -f "/usr/share/git/completion/git-prompt.sh" ]; then
  # ArchLinux location
  GIT_PROMPT_LOCATION="/usr/share/git/completion/git-prompt.sh"
elif [ -f "/usr/share/git/git-prompt.sh" ]; then
  # Gentoo location
  GIT_PROMPT_LOCATION="/usr/share/git/git-prompt.sh"
fi

if [ -n "${GIT_PROMPT_LOCATION}" ] && [ -f "${GIT_PROMPT_LOCATION}" ]; then
  # shellcheck ignore=SC1090 # don't inspect sources outside the repo
  . "${GIT_PROMPT_LOCATION}"
  __git_ps1
fi
