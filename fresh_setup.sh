#!/bin/bash

set -o errexit

if [ ${EUID} = 0 ]; then
  echo "This setup script should only be run in the context of the primary user."
  exit 1
fi

source /etc/os-release

if [ "${NAME}" != "Fedora" ]; then
  echo "These setup scripts are only targetting Fedora. It looks like you're trying to run this on another distro."
  exit 1
fi

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
  export DESKTOP_ENABLED="y"
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

if ask_default_no 'Would you like to install the embedded/electronic design tools?'; then
  ROOT_SCRIPTS+=('embedded_development.sh')
  # This is used by the rust script to determine whether to install the embedded rust tooling
  export EMBEDDED_DEVELOPMENT="y"
fi

if ask_default_yes 'Would you like to install podman?'; then
  ROOT_SCRIPTS+=('podman.sh')
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

echo

echo "I'm going to run the following root scripts:"
for script in ${ROOT_SCRIPTS[*]}; do
  echo -e "\t* ${script}"
done
echo

if [ ${#USER_SCRIPTS[@]} -gt 0 ]; then
  echo "...and the following user scripts: ${USER_SCRIPTS[*]}"
  for script in ${USER_SCRIPTS[*]}; do
    echo -e "\t* ${script}"
  done
fi

if ask_default_no 'Are you ready to do this?'; then
  # Start by testing / prompting for root permissions, will abort if the user Ctrl-C's out of this request
  sudo echo

  # Build a singular root script so we don't have to worry about sudo timing out half way through
  echo -e '#!/bin/bash\n\n' | sudo tee /tmp/setup_script.sh > /dev/null
  for script in ${ROOT_SCRIPTS[*]}; do
    cat setup-scripts/${script} | sudo tee -a /tmp/setup_script.sh > /dev/null
  done

  sudo chmod +x /tmp/setup_script.sh
  #sudo /tmp/setup_script.sh
  #sudo rm -f /tmp/setup_script.sh

  # For user scripts we can just run them directly as we don't have to worry about timeouts
  #for script in ${USER_SCRIPTS[*]}; do
  #  ./setup-scripts/${script}
  #done
fi
