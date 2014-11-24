
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

alias gl='git log --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset%s %Cgreen(%cr) %C(bold blue)<%an>%Creset" --abbrev-commit --date=rfc'

# Fuck this command search bull shit
unset command_not_found_handle

alias gs='git status'
alias gr='git fetch && git rebase origin/master'
alias db_prep='rm db/*.sqlite3; rm db/*.db; rake db:migrate && rake db:seed && rake db:test:prepare'
alias octal='stat -c "%A %a %n"'
alias dig='dig +nocmd +noall +answer'

export PATH="$HOME/.dotfiles/bin:$PATH"
export HISTCONTROL="ignoredups"
export HISTTIMEFORMAT="%F %T "
export GOPATH="${HOME}/src/go"

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
  # Load RVM into a shell session *as a function*
  [[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"
fi

# Load RBENV if it's setup
if [ -d $HOME/.rbenv ]; then
  export PATH="$HOME/.rbenv/bin:$PATH"
  eval "$(rbenv init -)"
fi

# Source the file that gives us our prompt function
source $HOME/.dotfiles/helpers/git-prompt.sh
source $HOME/.dotfiles/helpers/sagent.sh

unset LESSOPEN
export VAGRANT_DEFAULT_PROVIDER=libvirt
