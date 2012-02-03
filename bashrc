# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
  . /etc/bashrc
fi


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
  export PS1="\W \[$YELLOW\]\$(__git_ps1)\[$RST\] \$(exitstatus) "
else 
  export PS1="[\u@\h \W] \$GITSTATUS \$(exitstatus) "
fi

#export PS1="[\u@\h \W]\$ "

# Load RVM up
[[ -s "/home/sstelfox/.rvm/scripts/rvm" ]] && source "/home/sstelfox/.rvm/scripts/rvm"
