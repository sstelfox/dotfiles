#!/usr/bin/env

function personal_ps1_prompt() {
  #local __bat_status="\$(${DOTFILES_DIR}/helpers/battery_status.sh)"
  local __bat_status=""
  #local __exit_status="\$(${DOTFILES_DIR}/helpers/exit_status.sh $?)"
  local __exit_status=""
  #local __git="\[${BLUE}\]\$(${DOTFILES_DIR}/helpers/git-ps1-wrapper.sh)\[${RST}\]"
  local __path="\$(${DOTFILES_DIR}/helpers/shortdir.sh)"
  local __user_host="[\u@\h]"

  echo "$__bat_status$__exit_status $__path$__git \\$"
}

function setup_prompt {
  export PS1="$(personal_ps1_prompt) "

  # Don't expose more than path through the window title...
  export PROMPT_COMMAND='echo -en "\033]0;${PWD/#${HOME}/\~}\a"'
}

#setup_prompt
