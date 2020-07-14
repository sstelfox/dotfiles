
# Source global definitions
if [ -f /etc/bashrc ]; then
  source /etc/bashrc
fi

# Enable globstar matching
shopt -s globstar

# Ensure we append to the history file rather than replacing it
shopt -s histappend

# When a command was run that spanned multiple lines, merge that into a single
# history entry for the purposes of looking back.
shopt -s cmdhist

# Disable the XON/XOFF flow control completely (Ctrl-Q/Ctrl-S). Damn this is an
# annoying legacy feature...
if [ -t 0 ]; then
  stty -ixon
fi

# If we're running interactively (such as through rsync, sftp etc) don't execute the following code
if [[ $- != *i* ]]; then
  return
fi

# Encoding help?
export LC_ALL=en_US.utf-8
export LANG="$LC_ALL"
export TZ="America/Chicago"

# Big surprise? I think not
export EDITOR="vim"

# Source all executable files that live the system-specific folder
for FILE in $HOME/.dotfiles/system-specific/*; do
  if [[ -x "$FILE" ]]; then
    source $FILE
  fi
done

alias gl='git log --graph --pretty=format:"%Cred%h%Creset - %G? %C(yellow)%d%Creset%s %Cgreen(%cr) %C(bold blue)<%an>%Creset" --abbrev-commit --date=rfc'
alias gt='git log --tags --simplify-by-decoration --pretty="format:%ai %d"'

# Fuck this command search bull shit
unset command_not_found_handle

alias gs='git status'
alias gr='git fetch && git rebase origin/master'
alias db_prep='rm db/*.sqlite3; rm db/*.db; rake db:migrate && rake db:seed && rake db:test:prepare'
alias octal='stat -c "%A %a %n"'
#alias dig='dig +nocmd +noall +answer'

alias vi='vim'
alias gdb='gdb -q'

# Shortcut for generating a QR code in the command line
alias qr='echo "$@" | qrencode -m 3 -t UTF8 -o -'

#if [ ! -d "${HOME}/.azure" ]; then
#  mkdir "${HOME}/.azure"
#  chmod 0750 "${HOME}/.azure"
#fi
#alias az='podman run -it --rm --security-opt label=disable -v "${HOME}/.azure:/root/.azure" --entrypoint /usr/local/bin/az mcr.microsoft.com/azure-cli:latest'

#[ -f "${HOME}/.terraform_env" ] || touch "${HOME}/.terraform_env"
#alias terraform='podman run -it --rm --env-file "${HOME}/.terraform_env" --security-opt label=disable -v $(pwd):/run/current -w /run/current docker.io/hashicorp/terraform:light'

export PATH="/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usrc/local/bin:$HOME/.dotfiles/bin:$HOME/go_install/go/bin:$HOME/bin:$HOME/.gem/ruby/2.4.0/bin:$HOME/.cargo/bin:$HOME/node_modules/yarn/bin"

if [ -d "$HOME/go_install/go" ]; then
  export GOROOT="$HOME/go_install/go"
fi

# You know what I really need? An archive of every bash command I ever run in
# the future...
if [ ! -d "${HOME}/.dotfiles/bash-histories" ]; then
  mkdir -p "${HOME}/.dotfiles/bash-histories"
fi

export HISTCONTROL="ignoreboth"
export HISTIGNORE="ls:bg:fg:history"
export HISTSIZE=-1
export HISTTIMEFORMAT="%F %T "

# For Go
export GOPATH="${HOME}/workspace/golang"
export PATH="$PATH:$GOPATH/bin"

# And for RVM
export PATH="$PATH:$HOME/.rvm/bin"
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" &> /dev/null
if declare -F rvm &> /dev/null; then
  rvm use default &> /dev/null
fi

# Some color definitions
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
BLUE=$(tput setaf 5)
RST=$(tput sgr0)

#GOOD=$(echo -e '\xE2\x9C\x93')
GOOD=$(echo +)
BAD="-"

DOTFILES_DIR="$HOME/.dotfiles"

function personal_ps1_prompt() {
  local __user_host="[\u@\h]"
  local __path="\$($DOTFILES_DIR/bin/shortdir)"
  local __git="\[$BLUE\]\$($DOTFILES_DIR/bin/git-ps1-wrapper.sh)\[$RST\]"
  local __exit_status="\$($DOTFILES_DIR/bin/exit_status $?)"
  local __bat_status="\$($DOTFILES_DIR/bin/bat_status PS1)"

  if [[ -n "$TMUX_PANE" ]]; then
    echo "$__bat_status$__exit_status $__path$__git \\$"
  else
    echo "$__bat_status$__exit_status $__user_host $__path$__git \\$"
  fi
}

function setup_prompt {
  export PS1="$(personal_ps1_prompt) "

  # Don't expose more than path through the window title...
  export PROMPT_COMMAND='echo -en "\033]0;${PWD/#$HOME/\~}\a"'

  # Flush our history after every command as well...
  export PROMPT_COMMAND="${PROMPT_COMMAND}; history -a"
}

# Setup PS1 variable
setup_prompt

# If the rust toolchain in installed source it's environment
if [ -f $HOME/.cargo/env ]; then
  source $HOME/.cargo/env
fi

if [ -n "${DESKTOP_SESSION}" ]; then
  # Bump up our file descriptor count from the default, only in the desktop environments thogh
  ulimit -n 524288
fi

# Source the file that gives us our prompt function
source $HOME/.dotfiles/helpers/git-prompt.sh
#source $HOME/.dotfiles/helpers/sagent.sh
source $HOME/.dotfiles/helpers/gpg-agent.sh

unset LESSOPEN
unset SSH_ASKPASS
