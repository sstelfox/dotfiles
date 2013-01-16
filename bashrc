# Source global definitions
if [ -f /etc/bashrc ]; then
  source /etc/bashrc
fi

# If we're running interactively (such as through rsync, sftp etc) don't execute the following code
if [[ $- != *i* ]]; then
  return
fi

if [ -e /usr/share/terminfo/x/xterm-256color -a "$TERM" != "xterm-256color" ]; then
  export TERM='xterm-256color'
else
  export TERM='xterm-color'
fi

# Encoding help?
export LC_ALL=en_US.utf-8
export LANG="$LC_ALL"

# Big surprise? I think not
export EDITOR="vim"

# Test to ensure we have tmux before automatically executing it..
#if which tmux 2>&1 >/dev/null; then
  # If we're not in a tmux session already open one up that will automatically close when we exit or detach
#  if [[ "$TERM" != "screen" ]]; then
    #tmux && exit 
#  fi
#fi

# Source all executable files that live the system-specific folder
for FILE in $HOME/.dotfiles/system-specific/*; do
  if [[ -x "$FILE" ]]; then
    source $FILE
  fi
done

# Fuck this command search bull shit
unset command_not_found_handle

alias gl='git log --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset%s %Cgreen(%cr) %C(bold blue)<%an>%Creset" --abbrev-commit --date=relative'
alias gs='git status'
alias guard='bundle exec guard'
alias db_prep='rm db/*.sqlite3; rm db/*.db; rake db:migrate && rake db:seed && rake db:test:prepare'

export PATH="$HOME/.dotfiles/bin:$PATH"

# Function that allows some quick directory traversing
function go {
  if [[ "$1" = "b" ]]; then
    popd > /dev/null
  elif [[ "$1" = "rp" ]]; then
    pushd $HOME/ruby_projects > /dev/null
  elif [[ "$1" = "dot" ]]; then
    pushd $HOME/.dotfiles > /dev/null
  else
    pushd $HOME > /dev/null
  fi
}

# Source the git-completion file
source $HOME/.dotfiles/helpers/git-completion.sh
source $HOME/.dotfiles/helpers/ssh-agent.sh

# Some color definitions
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
YELLOW=$(tput bold; tput setaf 3;)
RST=$(tput sgr0)

#GOOD=$(echo -e '\xE2\x9C\x93')
GOOD=$(echo +)
BAD=$(echo -)

function exit_status {
  if [ "$?" -eq "0" ]; then
    echo $GOOD
  else
    echo $BAD
  fi
}

function setup_prompt {
  local __user_host="[\u@\h]"
  local __path="\W"
  local __git="\[$YELLOW\]$(__git_ps1)\[$RST\]"
  local __exit_status="\$(exit_status)"

  if [[ "$TERM" == "screen" ]]; then
    export PS1="$__path$__git $__exit_status "
  else 
    export PS1="$__user_host $__path$__git $__exit_status "
  fi
}
# Setup PS1 variable
#setup_prompt

# For when I inevitable break my PS1...
if [[ -n "$TMUX_PANE" ]]; then
  export PS1="\$($HOME/.dotfiles/bin/shortdir)\[$YELLOW\]\$(__git_ps1)\[$RST\] \$(exit_status) "
else 
  export PS1="[\u@\h \$($HOME/.dotfiles/bin/shortdir)]\[$YELLOW\]\$(__git_ps1)\[$RST\] \$(exit_status) "
fi

# Load RVM up if it's setup
if [ -d "$HOME/.rvm" ]; then
  [[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

  # RVM doesn't always seem to come up properly for me, this does the trick
  rvm reload > /dev/null

  PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting
fi

# Load RBENV if it's setup
if [ -d $HOME/.rbenv ]; then
  export PATH="$HOME/.rbenv/bin:$PATH"
  eval "$(rbenv init -)"
fi
