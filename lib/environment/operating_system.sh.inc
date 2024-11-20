#!/usr/bin/env false

function detect_os() {
  if [ -n "${TERMUX_VERSION:-}" ]; then
    echo "termux"
    return 0
  fi


  # If we're on a system that supports the os-release meta, we can learn a lot about where we're
  # running. For this function we only care about one variable it provides.
  if [ -f /etc/os-release ]; then
    source /etc/os-release

    # Detect the variations that are relevant to me
    case "${ID}" in
      "alpine")
        echo "alpine"
        return 0
        ;;
      "arch")
        echo "arch"
        return 0
        ;;
      "centos")
        echo "centos"
        return 0
        ;;
      "debian")
        echo "debian"
        return 0
        ;;
      "fedora")
        echo "fedora"
        return 0
        ;;
      "gentoo")
        echo "gentoo"
        return 0
        ;;
      "ubuntu")
        echo "ubuntu"
        return 0
        ;;
    esac
  fi

  # Silly Apple devices, can't follow a single standard...
  if [ "x$(uname)" = "xDarwin" ]; then
    echo "macos"
    return 0
  fi

  # Fall back on the least common denominator, we know we're at least on a POSIX system by the
  # nature of these scripts running
  echo "posix"
  return 0
}

detect_os_family() {
  if [ -n "${TERMUX_VERSION:-}" ]; then
    echo "android"
    return 0
  fi

  case "$(uname)" in
    "Darwin")
      echo "macos"
      ;;
    "Linux")
      echo "linux"
      ;;
    *)
      echo "unknown"
      ;;
  esac

  return 0
}
