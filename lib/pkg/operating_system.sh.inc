#!/usr/bin/env false

arch_linux_pkg_install() {
  local pkg_list="${1:-}"

  if [ -z "${pkg_list}" ]; then
    echo "must provide a package list to install to arch_linux_pkg_install"
    return 1
  fi

  local cmd_prefix=""

  # We need to escalate our privileges to perform the package installation, but only do so if we
  # aren't already running with privileges.
  if ! is_privileged; then
    cmd_prefix="sudo"
  fi

  pkg_install_cmd="${cmd_prefix} pacman -Sy --needed --noconfirm ${pkg_list}"

  return 0
}

macos_pkg_install() {
  # This is a hard one as the packages can come from a few different locations and may need to
  # fallback on a shell installer. At the beginning we'll only support homebrew

  echo 'macos package instllation is incomplete!'
  return 1
}

os_pkg_install() {
  local common_pkg_name="${1:-}"

  if [ -z "$common_pkg_name" ]; then
    echo "usage: ensure_os_pkg_present PACKAGE_NAME" >&2
    return 1
  fi

  # All our package specific operations are OS dependent so we need to identify what we're running
  # on.
  local os_name
  os_name="$(detect_os)"
  local os_status=$?

  if [ "${os_status}" -ne 0 ]; then
    echo "failed to detect OS for package mapping and installation (err:${os_status})" >&2
    return 2
  fi

  # Operating systems have different names, and sometimes split the same functionality across
  # several packages. This managed function will ONLY attempt to install packages where we have an
  # explicit mapping for that OS. We never try to fall back on just trying the name as that may have
  # unintended consequences.
  local os_pkgs
  os_pkgs="$(get_os_pkg_equivalent "${os_name}" "${common_pkg_name}")"
  local os_pkgs_status=$?

  if [ "${os_pkgs_status}" -ne 0 ]; then
    echo "unable to perform package equivalence lookup for ${common_pkg_name} on ${os_name} (err:${os_pkgs_status})" >&2
    return 3
  fi

  # TODO: Once I've plumbed my system specific profiles in through this library, I should add any
  # packages that are relevant based on my profile tags if a OS specific tag file is present. Any
  # packages detected this way should be appended to the ${os_pkgs} variable.

  echo "ensuring ${common_pkg_name} packages are present..." >&2

  local pkg_install_cmd
  case "${os_name}" in
    arch)
      arch_linux_pkg_install "${os_pkgs}"
      ;;
    *)
      echo "no package installation command available for ${os_name}" >&2
      return 4
      ;;
  esac

  if ! eval "${pkg_install_cmd}" >/dev/null 2>&1; then
    echo "failed to install ${os_pkgs} on ${os_name}" >&2
    return 5
  fi

  echo "all ${common_pkg_name} packages are present" >&2
  return 0
}

get_os_pkg_equivalent() {
    local os_name="${1:-}"
    local pkg_name="${2:-}"

    if [ -z "${os_name}" ] || [ -z "${pkg_name}" ]; then
        echo "usage: get_os_pkg_equivalent OS_NAME PACKAGE_NAME" >&2
        return 1
    fi

    local map_file="${__DATA_PATH}/os_pkg_maps/${os_name}.map"

    if [ ! -f "${map_file}" ]; then
        echo "no package mapping file found for OS ${os_name}" >&2
        return 2
    fi

    # Look for lines starting with the package name followed by a space...
    local pkg_line
    pkg_line="$(grep "^${pkg_name} " "$map_file" || true)"

    if [ -z "$pkg_line" ]; then
        echo "no package mapping found for '${pkg_name}' on ${os_name}" >&2
        return 3
    fi

    # ...take everything on the same line afterwards. Does not support trailing comments but
    # line-oriented comments are fine
    echo "$pkg_line" | sed "s/^${pkg_name}[[:space:]]*//g"
    return 0
}
