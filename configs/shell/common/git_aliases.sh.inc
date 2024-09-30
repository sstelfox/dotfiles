#!/usr/bin/env false

alias ga='git log --diff-filter=A --follow --format=%aI -- '
alias gb='git branch --sort=-committerdate | head -n 20'
alias gl='git log --graph --pretty=format:"%Cred%h%Creset - %G? %C(yellow)%d%Creset%s %Cgreen(%cr) %C(bold blue)<%an>%Creset" --abbrev-commit --date=rfc'
alias gr='git fetch && git rebase origin/main'
alias gs='git status'
alias gt='git log --tags --simplify-by-decoration --pretty="format:%ai %d"'
