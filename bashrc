
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

# If we're running interactively (such as through rsync, sftp etc) don't setup
# the user environment
if [[ $- != *i* ]]; then
  return
fi

# Disable the XON/XOFF flow control completely (Ctrl-Q/Ctrl-S). Damn this is an
# annoying legacy feature...
if [ -t 0 ]; then
  stty -ixon
fi

# Big surprise? I think not
export EDITOR="vim"

# Source all executable files that live the system-specific folder
for FILE in $HOME/.dotfiles/system-specific/*; do
  if [[ -x "$FILE" ]]; then
    source $FILE
  fi
done

alias gb='git branch --sort=-committerdate | head -n 20'
alias gl='git log --graph --pretty=format:"%Cred%h%Creset - %G? %C(yellow)%d%Creset%s %Cgreen(%cr) %C(bold blue)<%an>%Creset" --abbrev-commit --date=rfc'
alias glroot='git log --graph --pretty=format:"%Cred%h%Creset - %G? %C(yellow)%d%Creset%s %Cgreen(%cr) %C(bold blue)<%an>%Creset" --abbrev-commit --date=rfc --first-parent'
alias gs='git status'

# Fuck this command search bull shit
unset command_not_found_handle

alias octal='stat -c "%A %a %n"'
alias dig='dig +nocmd +noall +answer'

export PATH="$HOME/.dotfiles/bin:/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin:$HOME/.cargo/bin:$HOME/.rvm/bin"

export HISTCONTROL="ignoreboth"
export HISTIGNORE="ls:bg:fg:history"
export HISTSIZE=-1
export HISTTIMEFORMAT="%F %T "

DOTFILES_DIR="$HOME/.dotfiles"

function personal_ps1_prompt() {
  local __user_host="[\u@\h]"
  local __path="\$($DOTFILES_DIR/scripts/shortdir)"
  local __git="\$($DOTFILES_DIR/scripts/git-ps1-wrapper.sh)"

  if [[ -n "$TMUX_PANE" ]]; then
    echo "$__path$__git \\$"
  else
    echo "$__user_host $__path$__git \\$"
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

unset LESSOPEN
unset SSH_ASKPASS

source ${DOTFILES_DIR}/scripts/gpg-agent.sh

# minim ops related settings
export TF_VAR_custom_bastion_user=$(whoami)
export TF_VAR_custom_bastion_private_key=~/.ssh/provisioning.pub
export TF_VAR_chr_provisioning_password=dootdootdootnotreal
export EXTRA_ANSIBLE_SSH_ARGS="-i ~/.ssh/provisioning.pub"

# NetworkManager is absolute trash and doesn't allow you to set these, so we
# have to fallback on env variables
export RES_OPTIONS="edns0 trust-ad"
