#!/usr/bin/env false

personal_ps1_prompt() {
  user_host=""
  if [ -z "${TMUX}" ]; then
    user_host="[\u@\h] "
  fi

  if [ -n "${__DOTFILE_ROOT}" ]; then
    #bat_status="\$(${__DOTFILE_ROOT}/helpers/battery_status.sh)"
    bat_status=""

    path="\$(${__DOTFILE_ROOT}/helpers/shortdir.sh)"
    git="\$(${__DOTFILE_ROOT}/helpers/git-ps1-wrapper.sh)"

    echo "${user_host}${bat_status} ${path}${git} \\$ "
  else
    echo "${user_host} \\$ "
  fi
}

setup_prompt() {
  # shellcheck disable=SC2155 # special variable already declared
  export PS1="$(personal_ps1_prompt)"
}

setup_prompt
