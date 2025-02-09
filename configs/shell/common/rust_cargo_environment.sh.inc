#!/usr/bin/env false

if [ -f "${HOME}/.cargo/env" ]; then
  # shellcheck disable=SC1091 # shellcheck doesn't follow this even if its present, don't check
  # this script that is outside our repo.
  . "${HOME}/.cargo/env"

  alias cargo-terse-issues="cargo check --tests --bins --message-format=short"
fi
