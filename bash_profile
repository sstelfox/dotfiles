# .bash_profile

# Source the main shell setting file
if [ -f ~/.bashrc ]; then
  . ~/.bashrc
fi

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

if [ -e /home/sstelfox/.nix-profile/etc/profile.d/nix.sh ]; then . /home/sstelfox/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer
