#!/usr/bin/env false

STOCK_VIM="$(which -a vim 2>/dev/null | grep -e '^/' | head -n 1)"

if [ $? -eq 0 ]; then
  # We'll explicitly set this as our editor if its available, later on this will be overridden if
  # we have a better option available.
  export EDITOR="${STOCK_VIM}"

  # Some sanity checking along with a useful error messages if I try on a system that doesn't have
  # a copy of my docs
  if [ -d "${HOME}/documentation" ]; then
    alias ap="${STOCK_VIM} ~/documentation/passwords.txt"
  else
    alias ap="echo 'documentation unavailable on this machine' >&2"
  fi
else
  # Let's also give a useful error message under these conditions
  alias ap="echo 'stock vim unavailable on this machine' >&2 && false"
fi

# If we have our preferred editor available we should use this instead and make sure my muscle
# memory gets us to the right location
NEO_VIM="$(which nvim 2>/dev/null | grep -e '^/' | head -n 1)"

if [ $? -eq 0 ]; then
  alias vi="${NEO_VIM}"
  alias vim="${NEO_VIM}"

  # This is an extra little helper that might be better moved to my shell library and then called...
  alias sync_nvim_plugins='nvim --headless -c "lua require('packer').sync()" -c "quitall"'

  export EDITOR="${NEO_VIM}"
fi

# Don't pollute
unset NEO_VIM STOCK_VIM
