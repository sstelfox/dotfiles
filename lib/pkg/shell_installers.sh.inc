#!/usr/bin/env false

get_installer_info() {
  local installer_name="${1:-}"

  if [ -z "${installer_name}" ]; then
    echo "usage: get_installer_info INSTALLER_NAME" >&2
    return 1
  fi

  local map_file="${__DATA_PATH}/shell_installers.map"

  if [ ! -f "${map_file}" ]; then
    echo "no installer mapping file found" >&2
    return 2
  fi

  # Look for lines starting with the installer name followed by a space
  local installer_line
  installer_line="$(grep "^${installer_name} " "${map_file}" || true)"

  if [ -z "${installer_line}" ]; then
    echo "no installer mapping found for '${installer_name}'" >&2
    return 3
  fi

  # Return everything after the installer name and whitespace
  echo "${installer_line}" | sed "s/^${installer_name}[[:space:]]*//g"
  return 0
}

# Safely handles downloading and executing third-party installer scripts
shell_pkg_install() {
  local installer_name="${1:-}"
  local custom_args="${2:-}"

  if [ -z "${installer_name}" ]; then
    echo "usage: handle_remote_installer INSTALLER_NAME [CUSTOM_ARGS]" >&2
    return 1
  fi

  # Lookup the details of the named installer
  local installer_data
  installer_data="$(get_installer_info "${installer_name}")"
  local lookup_status=$?

  if [ "${lookup_status}" -ne 0 ]; then
    echo "failed to lookup installer data for ${installer_name} (err:${lookup_status})" >&2
    return 2
  fi

  # Parse the installer data (format: url|hash|default_args)
  local url hash default_args
  url="$(echo "${installer_data}" | cut -d'|' -f1)"
  hash="$(echo "${installer_data}" | cut -d'|' -f2)"
  default_args="$(echo "${installer_data}" | cut -d'|' -f3)"

  # Create somewhere safe to place the downloaded installer
  local tmp_dir
  tmp_dir="$(mktemp -d)" || {
    echo "failed to create temporary directory" >&2
    return 3
  }

  # A subshell is used here so we can ensure we clean up the temporary directory once the excution
  # is complete
  (
    chmod 700 "${tmp_dir}" || {
        echo "failed to set secure permissions on temporary directory" >&2
        return 4
    }

    local script_path="${tmp_dir}/installer.sh"
    echo "downloading installer for ${installer_name}..." >&2

    # Download the script using curl, but enforce some security requirements and allow for some
    # ephemeral failures
    if ! curl -fsSL --proto '=https' --tlsv1.2 --connect-timeout 10 --max-time 30 --retry 3 --retry-delay 1 --output "${script_path}" "${url}"; then
      echo "failed to download installer script" >&2
      return 5
    fi

    local actual_hash
    if ! actual_hash="$(sha256sum "${script_path}" | cut -d' ' -f1)"; then
      echo "failed to calculate installer hash" >&2
      return 6
    fi

    # If I've recorded a specific sha256sum for the installer, validate it before continuing
    if [ -n "${hash}" ]; then
      echo "verifying installer hash..." >&2

      if [ "${actual_hash}" != "${hash}" ]; then
        echo "installer hash mismatch!" >&2
        echo "expected: ${hash}" >&2
        echo "got:      ${actual_hash}" >&2
        return 7
      fi
    else
      # If I haven't well... here's my opportunity to do so...
      echo "warning: no hash verification available for ${installer_name}" >&2
      echo "warning: ${installer_name} has sha256sum ${actual_hash}" >&2
    fi

    # Make sure what we downloaded is actually a script of some kind...
    if ! head -n1 "${script_path}" | grep -q '^#!.*sh'; then
      echo "warning: script does not appear to have a shell shebang" >&2
    fi

    # Make script executable
    chmod +x "${script_path}" || {
      echo "failed to make installer script executable" >&2
      return 8
    }

    # Construct the execution command
    local exec_cmd="${script_path}"

    # Add default args if present
    if [ -n "${default_args}" ]; then
      exec_cmd="${exec_cmd} ${default_args}"
    fi

    # Add additional custom args if provided
    if [ -n "${custom_args}" ]; then
      exec_cmd="${exec_cmd} ${custom_args}"
    fi

    echo "executing ${installer_name} installer..." >&2

    if ! eval "${exec_cmd}"; then
      echo "installer execution failed" >&2
      return 9
    fi

    # TODO: Should reset the shell runtime configuration files after the install. I handle things
    # like path modifications and aliases myself and these almost always pollute the environment
    # unecessarily and universally.
    #
    # Supporting this should cause this function to abort early if there are uncommitted changes to
    # files an install script may modify (just limit it to the ones we'll automatically reset,
    # which should likely be a single local variable for maintenance purposes).

    echo "${installer_name} installation completed successfully" >&2
    rm -rf "${tmp_dir}"
    return 0
  )
}
