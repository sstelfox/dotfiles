#!/usr/bin/env false

rebuild_ssh_config() {
  local ssh_client_cfg_base="${__DOTFILE_ROOT}/configs/ssh"
  local ssh_client_cfg="${ssh_client_cfg_base}/config"

  # truncate the existing config file
  cat /dev/null > "${ssh_client_cfg}"

  # throw in the base common config, general best practices and defaults
  cat "${ssh_client_cfg_base}/base.cfg.inc" > "${ssh_client_cfg}"
  printf "\n" >> "${ssh_client_cfg}"

  # shared configs that live permanently in my repo
  for file in "${ssh_client_cfg_base}/common/"*.cfg.inc; do
    cat "${file}" >> "${ssh_client_cfg}"
    printf "\n" >> "${ssh_client_cfg}"
  done

  # and lastly system specific configurations, we have to do a little dance here as this directory
  # may be empty.
  set -- "${ssh_client_cfg_base}/system/"*.cfg.inc
  if [ -e "$1" ]; then
    for file; do
      cat "${file}" >> "${ssh_client_cfg}"
      printf "\n" >> "${ssh_client_cfg}"
    done
  fi
}

set_default_ssh_key() {
  local ssh_dir="${HOME}/.ssh"
  local target_key="${1:-}"

  if [ -z "${target_key}" ]; then
    echo "set_default_ssh_key unable to set default ssh key, requires a target key" >&2
    echo "usage: set_default_ssh_key <target_key>" >&2
    return 1
  fi

  if [ ! -e "${ssh_dir}/${target_key}" ]; then
    echo "set_default_ssh_key unable to set default ssh key, target key ${ssh_dir}/${target_key} does not exist" >&2
    return 1
  fi

  if [ -L "${ssh_dir}/default-system-key" ]; then
    readlink "${ssh_dir}/default-system-key" | grep -q "${target_key}" && return 0
  fi

  ln -sf "${ssh_dir}/${target_key}" "${ssh_dir}/default-system-key"
  chmod 0600 "${ssh_dir}/default-system-key"
  return 0
}

autoselect_default_ssh_key() {
  local ssh_dir="${HOME}/.ssh"
  local pub_keys
  local pub_key_count
  local default_pub_key

  # Ensure the ssh directory exists
  if [ ! -d "${ssh_dir}" ]; then
    echo "autoselect_default_ssh_key unable to set default ssh key, ssh directory ${ssh_dir} does not exist" >&2
    return 1
  fi

  # Check if a default key symlink already exists
  if [ -L "${ssh_dir}/default-system-key" ]; then
    return 0
  fi

  # Find all pub keys in the ssh directory
  pub_keys=$(find "${ssh_dir}" -maxdepth 1 -maxdepth 1 -type f -name "*.pub" 2>/dev/null)
  pub_key_count=$(echo "${pub_keys}" | wc -l)

  if [ "${pub_key_count}" -eq 0 ]; then
    echo "autoselect_default_ssh_key unable to set default ssh key, no public keys found in ${ssh_dir}" >&2
    return 1
  fi

  if [ "${pub_key_count}" -gt 1 ]; then
    echo "autoselect_default_ssh_key unable to set default ssh key, multiple public keys found, cannot choose a default" >&2
    return 1
  fi

  # If there is only one pub key, use it as the default
  default_pub_key=$(echo "${pub_keys}")
  set_default_ssh_key "${default_pub_key##*/}"
  return 0
}
