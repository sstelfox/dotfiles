#!/usr/bin/env false

firefox_fix() {
  # Fixes a weird enforced install helper bug in firefox after updates
  if [ -d "${HOME}/Library/Caches/Mozilla" ]; then
    rm -rf "${HOME}/Library/Caches/Mozilla"
  fi
}
