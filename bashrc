
# Source global definitions
if [ -f /etc/bashrc ]; then
  source /etc/bashrc
fi

# Enable globstar matching
shopt -s globstar

# If we're running interactively (such as through rsync, sftp etc) don't execute the following code
if [[ $- != *i* ]]; then
  return
fi

# Encoding help?
export LC_ALL=en_US.utf-8
export LANG="$LC_ALL"
export TZ="America/New_York"

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
alias dig='dig +nocmd +noall +answer'

alias vi='vim'
alias gdb='gdb -q'

# Shortcut for generating a QR code in the command line
alias qr='echo "$@" | qrencode -m 3 -t UTF8 -o -'

export PATH="$HOME/.dotfiles/bin:$HOME/go_install/go/bin:$HOME/bin:$HOME/.gem/ruby/2.4.0/bin:$HOME/.cargo/bin:$PATH"

if [ -d "$HOME/go_install/go" ]; then
  export GOROOT="$HOME/go_install/go"
fi

# You know what I really need? An archive of every bash command I ever run in
# the future...
if [ ! -d "${HOME}/.dotfiles/bash-histories" ]; then
  mkdir -p "${HOME}/.dotfiles/bash-histories"
fi

export HISTCONTROL="ignoreboth"
export HISTSIZE=-1
export HISTTIMEFORMAT="%F %T "

export GOPATH="${HOME}/workspace/golang"
export PATH="$PATH:$GOPATH/bin"

# Some color definitions
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
BLUE=$(tput setaf 5)
RST=$(tput sgr0)

GOOD=$(echo -e '\xE2\x9C\x93')
#GOOD=$(echo +)
BAD="-"

DOTFILES_DIR="$HOME/.dotfiles"

function setup_prompt {
  local __user_host="[\u@\h]"
  local __path="\$($DOTFILES_DIR/bin/shortdir)"
  local __git="\[$BLUE\]\$($DOTFILES_DIR/bin/git-ps1-wrapper.sh)\[$RST\]"
  local __exit_status="\$($DOTFILES_DIR/bin/exit_status $?)"

  if [[ -n "$TMUX_PANE" ]]; then
    export PS1="$__exit_status $__path$__git \\$ "
  else
    export PS1="$__exit_status $__user_host $__path$__git \\$ "
  fi

  # Don't expose more than path through the window title...
  export PROMPT_COMMAND='echo -en "\033]0;${PWD/#$HOME/\~}\a"'
}
# Setup PS1 variable
setup_prompt

# For when I inevitable break my PS1...
#if [[ -n "$TMUX_PANE" ]]; then
#  export PS1="\$($HOME/.dotfiles/bin/shortdir)\[$BLUE\]\$(__git_ps1)\[$RST\] \$(exit_status) "
#else
#  export PS1="[\u@\h \$($HOME/.dotfiles/bin/shortdir)]\[$BLUE\]\$(__git_ps1)\[$RST\] \$(exit_status) "
#fi

# Load RBENV if it's setup
if [ -d $HOME/.rbenv ]; then
  export PATH="$HOME/.rbenv/bin:$PATH"
  eval "$(rbenv init -)"
fi

# If the rust toolchain in installed source it's environment
if [ -f $HOME/.cargo/env ]; then
  source $HOME/.cargo/env
fi

# Source the file that gives us our prompt function
source $HOME/.dotfiles/helpers/git-prompt.sh
#source $HOME/.dotfiles/helpers/sagent.sh
source $HOME/.dotfiles/helpers/gpg-agent.sh

unset LESSOPEN
unset SSH_ASKPASS

export VAGRANT_DEFAULT_PROVIDER=libvirt
