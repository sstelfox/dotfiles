# Source global definitions
if [ -f /etc/bashrc ]; then
  . /etc/bashrc
fi

# If we're running interactively (such as through rsync, sftp etc) don't execute the following code
if [[ $- != *i* ]]; then
  return
fi

# Test to ensure we have tmux before automatically executing it..
#if which tmux 2>&1 >/dev/null; then
  # If we're not in a tmux session already open one up that will automatically close when we exit or detach
#  if [[ "$TERM" != "screen" ]]; then
    #tmux && exit 
#  fi
#fi

alias ga='git add'
alias gl='git log --format="%h - %an: %s"'
alias gs='git status'

# Some color definitions
RED=$(tput setaf 1)
YELLOW=$(tput setaf 3)
GREEN=$(tput setaf 3)
RST=$(tput sgr0)

CHECK=$(echo -e '\xE2\x9C\x93')
CROSS=$(echo x)

function exitstatus {
        EXITSTATUS="$?"

        if [ "$EXITSTATUS" -eq "0" ]; then
                echo "$CHECK"
        else
                echo "$CROSS"
        fi
}

if [[ -n "$TMUX_PANE" ]]; then
  export PS1="\W\[$YELLOW\]\$(__git_ps1)\[$RST\] \$(exitstatus) "
else 
  export PS1="[\u@\h \W] \$(exitstatus) "
fi

# Load RVM up
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"


