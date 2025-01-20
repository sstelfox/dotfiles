#!/usr/bin/env false

if [ -f "${HOME}/.cargo/env" ]; then
  source "${HOME}/.cargo/env"

  alias cargo-terse-issues="cargo check --tests --bins --message-format=short"
fi
