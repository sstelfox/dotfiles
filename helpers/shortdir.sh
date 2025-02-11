#!/usr/bin/env sh

set -o errexit
set -o nounset

is_unique_prefix() {
  dir="${1}"
  prefix="${2}"
  current="${3}" # Add current as a parameter to verify exact match

  # Escape special characters for grep
  escaped_prefix="$(printf "%s" "${prefix}" | sed 's/[]\[\^$.*]/\\&/g')"

  # Use ls -A to show hidden files, but not . and use grep to find matches that start with our
  # prefix
  matches="$(ls -A1 "${dir}" 2>/dev/null | grep "^${escaped_prefix}" || true)"

  # Count the matches
  match_count="$(printf "%s\n" "${matches}" | grep -c '^' || true)"

  # If we have exactly one match, verify it's the one we want
  if [ "${match_count}" -eq 1 ]; then
    # The match should exactly equal our current component
    [ "${matches}" = "${current}" ]
    return $?
  fi

  return 1
}

strlen() {
  expr length "${1}"
}

substr_start() {
  str="${1}"
  len="${2}"

  expr substr "${str}" 1 "${len}"
}

begin=""
shortbegin=""
current=""

case "${2:-}" in
"") end="$(pwd)/" ;;
*) end="${2}/" ;;
esac

case "${end}" in
"${HOME}"*)
  INHOME=1
  end="${end#"${HOME}"}"
  begin="${HOME}"
  ;;
*)
  INHOME=0
  ;;
esac

end="${end#/}"
shortenedpath="${end}"
maxlength="${1:-0}"

# shellcheck disable=SC2310
while [ -n "${end}" ] && [ "$(strlen "${shortenedpath}" || true)" -gt "${maxlength}" ]; do
  current="${end%%/*}"
  end="${end#*/}"

  shortcur="${current}"
  shortcurstar="${current}"

  curlen="$(strlen "${current}")"
  i="$((curlen - 2))"

  while [ "${i}" -ge 0 ]; do
    # Only try shortening if the current component is long enough
    if [ "${i}" -gt 0 ]; then
      subcurrent="$(substr_start "${current}" "${i}")"

      # shellcheck disable=SC2310 # desired behavior
      if is_unique_prefix "${begin}" "${subcurrent}" "${current}"; then
        # shellcheck disable=SC2034 # false detection
        shortcur="${subcurrent}"

        # shellcheck disable=SC2034 # false detection
        shortcurstar="${subcurrent}*"
      else
        break
      fi
    fi

    i="$((i - 1))"
  done

  begin="${begin}/${current}"
  shortbegin="${shortbegin}/${shortcurstar}"
  shortenedpath="${shortbegin}/${end}"
done

shortenedpath="${shortenedpath%/}"
shortenedpath="${shortenedpath#/}"

if [ "${INHOME}" -eq 1 ]; then
  # shellcheck disable=SC2088
  printf "~/%s\n" "${shortenedpath}"
else
  printf "/%s\n" "${shortenedpath}"
fi
