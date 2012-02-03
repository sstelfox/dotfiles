# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific aliases and functions

alias ga='git add'
alias gl='git log --format="%h - %an: %s"'
alias gs='git status'

# Some color definitions
#RED='\033[0;31m\]'
#YELLOW='\033[1;32m'
#GREEN='\033[1;32m'

RST='\033[m'

SUCCESS="$GREEN$(echo -e '\xE2\x9C\x93')\[$RST\]"
FAIL="$RED$(echo x)\[$RST\]"

#GITPS1="\$(__git_ps1 \" $YELLOW%s$RST\")"

function gitbranch {
        echo -e "${YELLOW}$(__git_ps1)\[${RST}\]"
}

function exitstatus {
        EXITSTATUS="$?"

        if [ "${EXITSTATUS}" -eq "0" ]; then
                echo "$SUCCESS"
        else
                echo "$FAIL"
        fi
}

function ps1smarts {
        STAT=$(exitstatus)
        GIT=$(gitbranch)

        echo -e "$GIT $STAT "
}

if [[ -n "$TMUX_PANE" ]]; then
  export PS1="\W\$(ps1smarts)"
else 
  export PS1="[\u@\h \W]\$(ps1smarts)"
fi

#export PS1="[\u@\h \W]\$ "

# Load RVM up
[[ -s "/home/sstelfox/.rvm/scripts/rvm" ]] && source "/home/sstelfox/.rvm/scripts/rvm"
