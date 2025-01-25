#!/usr/bin/env false

rebuild_ssh_config() {
  local ssh_client_cfg_base="${__DOTFILE_ROOT}/configs/ssh"
  local ssh_client_cfg="${ssh_client_cfg_base}/config"

  # truncate the existing config file
  cat /dev/null > "${ssh_client_cfg}"

  # throw in the base common config, general best practices and defaults
  cat "${ssh_client_cfg_base}/base" > "${ssh_client_cfg}"
  printf "\n" >> "${ssh_client_cfg}"

  # shared configs that live permanently in my repo
  for file in "${ssh_client_cfg_base}/common/"*; do
    cat "${file}" >> "${ssh_client_cfg}"
    printf "\n" >> "${ssh_client_cfg}"
  done

  # and lastly system specific configurations, we have to do a little dance here as this directory
  # may be empty.
  set -- "${ssh_client_cfg_base}/system/"*
  if [ -e "$1" ]; then
    for file; do
      cat "${file}" >> "${ssh_client_cfg}"
      printf "\n" >> "${ssh_client_cfg}"
    done
  fi
}
