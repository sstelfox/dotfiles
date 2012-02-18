# Source global definitions
if [ -f /etc/bashrc ]; then
  . /etc/bashrc
fi

# If we're running interactively (such as through rsync, sftp etc) don't execute the following code
if [[ $- != *i* ]]; then
  return
fi

# Source all executable files that live the system-specific folder
for FILE in $HOME/.dotfiles/system-specific/*; do
  if [[ -x "$FILE" ]]; then
    . $FILE
  fi
done

alias gl='git log --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset" --abbrev-commit --date=relative'
alias gstat='git status'
alias codecount='find . -type f -exec cat {} \; | wc -l'

# Some color definitions
#RED=$(tput setaf 1)
#YELLOW=$(tput setaf 3)
#GREEN=$(tput setaf 3)
#RST=$(tput sgr0)

#GOOD=$(echo -e '\xE2\x9C\x93')
GOOD=$(echo +)
BAD=$(echo -)

function exitstatus {
        EXITSTATUS="$?"

        if [ "$EXITSTATUS" -eq "0" ]; then
                echo "$GOOD"
        else
                echo "$BAD"
        fi
}

if [[ "$TERM" == "screen" ]]; then
  export PS1="\W\[$YELLOW\]\$(__git_ps1)\[$RST\] \$(exitstatus) "
else 
  export PS1="[\u@\h \W] \$(exitstatus) "
fi

# Load RVM up
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

# RVM doesn't always seem to come up properly for me, this does the trick
rvm reload > /dev/null

