#!/usr/bin/env false

install_font_macos() {
  force="${1:-}"
  font_path="${2:-}"

  if [ -z "${font_path}" ]; then
    echo "usage: install_font_macos [-f] <font_path>" >&2
    return 1
  fi

  font_name="$(basename "${font_path}")"
  dest_path="${HOME}/Library/Fonts/${font_name}"

  if [ -f "${dest_path}" ]; then
    if [ "${force}" = "-f" ]; then
      rm "${dest_path}" 2>/dev/null || return 2
    else
      return 2
    fi
  fi

  cp "${font_path}" "${dest_path}" 2>/dev/null || return 3
  return 0
}

install_font_linux() {
  force="${1:-}"
  font_path="${2:-}"

  if [ -z "${font_path}" ]; then
    echo "usage: install_font_linux [-f] <font_path>" >&2
    return 1
  fi

  font_name="$(basename "${font_path}")"
  dest_path="${HOME}/.fonts/${font_name}"

  mkdir -p "${HOME}/.fonts" 2>/dev/null || return 2

  if [ -L "${dest_path}" ]; then
    if [ "${force}" = "-f" ]; then
      rm "${dest_path}" 2>/dev/null || return 3
    else
      return 3
    fi
  fi

  ln -s "${font_path}" "${dest_path}" 2>/dev/null || return 4
  fc-cache -f 2>/dev/null || return 5
  return 0
}

install_font() {
  force=""
  font_name=""

  if [ "${1:-}" = "-f" ]; then
    force="-f"
    font_name="${2:-}"
  else
    font_name="${1:-}"
  fi

  if [ -z "${font_name}" ]; then
    echo "usage: install_font [-f] <font_name>" >&2
    exit 1
  fi

  font_files=""
  IFS_SAVE="${IFS}"
  IFS="$(printf '\n')"

  # shellcheck disable=SC2154  # Set by source including this file
  font_files="$(find "${__DOTFILE_ROOT}/fonts" -name "${font_name}-*.ttf" 2>/dev/null)"

  if [ -z "${font_files}" ]; then
    echo "No fonts found matching: ${font_name}" >&2
    IFS="${IFS_SAVE}"
    return 1
  fi

  os_family="$(detect_os_family)"

  case "${os_family}" in
    macos)
      echo "${font_files}" | while IFS= read -r font_path; do
        install_font_macos "${force}" "${font_path}" || { IFS="${IFS_SAVE}"; return 2; }
      done
      ;;
    linux)
      echo "${font_files}" | while IFS= read -r font_path; do
        install_font_linux "${force}" "${font_path}" || { IFS="${IFS_SAVE}"; return 2; }
      done
      ;;
    *)
      echo "font installation error: unsupported operating system: ${os_family}" >&2
      IFS="${IFS_SAVE}"
      return 1
      ;;
  esac

  IFS="${IFS_SAVE}"
  return 0
}
