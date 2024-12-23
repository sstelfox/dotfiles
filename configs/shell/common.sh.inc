#!/usr/bin/env false

# These includes expect my personal shell library shim to already be available. Make sure the base
# shell command, before including this one, has already sourced the shim.

# Core experience / UX
source "${__SHELL_CFG_ROOT}/common/dotfiles_path.sh.inc"

# Environment & path setup
source "${__SHELL_CFG_ROOT}/common/telemetry_opt_out.sh.inc"
source "${__SHELL_CFG_ROOT}/common/rust_cargo_environment.sh.inc"
source "${__SHELL_CFG_ROOT}/common/tfenv_setup.sh.inc"

# Convenience setup
source "${__SHELL_CFG_ROOT}/common/custom_dictionary.sh.inc"
source "${__SHELL_CFG_ROOT}/common/editor_config.sh.inc"
source "${__SHELL_CFG_ROOT}/common/git_aliases.sh.inc"
source "${__SHELL_CFG_ROOT}/common/password_store.sh.inc"

# Project / System / Organization environment specific setup
if [ "$(_plc detect_os)" = "macos" ]; then
  source "${__SHELL_CFG_ROOT}/operating_systems/docker_desktop.sh.inc"

  # Currently I don't have a better way to detect I'm in a Tulip environment but since this is the
  # only place I use a Mac...
  source "${__SHELL_CFG_ROOT}/environments/tulip_development.sh.inc"
fi
