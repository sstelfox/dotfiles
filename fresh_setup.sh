#!/bin/bash

source setup-scripts/_user_prelude.sh

ROOT_SCRIPTS=('base_setup.sh')
USER_SCRIPTS=()

function ask_default_no() {
  local prompt="${1}"

  read -p "${prompt} [N/y] " response
  case "${response}" in
    [nN])
      return 1
      ;;
    [yY])
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

function ask_default_yes() {
  local prompt="${1}"

  read -p "${prompt} [n/Y] " response
  case "${response}" in
    [nN])
      return 1
      ;;
    [yY])
      return 0
      ;;
    *)
      return 0
      ;;
  esac
}

if ask_default_yes 'Would you like to setup the system to be a desktop?'; then
  ROOT_SCRIPTS+=('desktop.sh')
  DESKTOP_ENABLED="y"
else
  DESKTOP_ENABLED="n"
fi

if ask_default_yes 'Would you like to setup nftables as the firewall?'; then
  ROOT_SCRIPTS+=('nftables.sh')
fi

if ask_default_yes 'Would you like to setup Rust?'; then
  ROOT_SCRIPTS+=('rust.sh')
fi

if ask_default_yes 'Would you like to setup Ruby?'; then
  ROOT_SCRIPTS+=('ruby_dependencies.sh')
  USER_SCRIPTS+=('ruby.sh')
fi

if ask_default_yes 'Would you like to install Yarn?'; then
  ROOT_SCRIPTS+=('yarn.sh')
fi

if ask_default_no 'Would you like to setup Golang?'; then
  ROOT_SCRIPTS+=('golang.sh')
fi

# Note to self, this should appear later in the array than Rust
if ask_default_no 'Would you like to install the embedded/electronic design tools?'; then
  ROOT_SCRIPTS+=('embedded_development.sh')
fi

if ask_default_no 'Would you like to install and setup Docker (deprecated)?'; then
  echo 'You idiot...'
  ROOT_SCRIPTS+=('docker.sh')
fi

# These questions only make sense if I enabled the desktop questions
if [ "${DESKTOP_ENABLED}" = "y" ]; then
  if ask_default_no 'Would you like to perform the laptop fixes?'; then
    ROOT_SCRIPTS+=('laptop_fixes.sh')
  fi

  if ask_default_no 'Would you like to install the art packages?'; then
    ROOT_SCRIPTS+=('art_packages.sh')
  fi
fi

echo "I'm going to run the following root scripts: ${ROOT_SCRIPTS[*]}"
echo "  ... and the following user scripts: ${USER_SCRIPTS[*]}"

if ask_default_no 'Are you ready to do this?'; then
  echo 'DOING THE THINGS...'
fi
