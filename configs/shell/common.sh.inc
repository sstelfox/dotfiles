#!/usr/bin/env false

# These includes expect my personal shell library shim to already be available. Make sure the base
# shell command, before including this one, has already sourced the shim.

# Environment setup
source "${__SHELL_CFG_ROOT}/common/dotfiles_path.sh.inc"
source "${__SHELL_CFG_ROOT}/common/telemetry_opt_out.sh.inc"
source "${__SHELL_CFG_ROOT}/common/rust_cargo_environment.sh.inc"
source "${__SHELL_CFG_ROOT}/common/tfenv_setup.sh.inc"

# Convenience setup
source "${__SHELL_CFG_ROOT}/common/custom_dictionary.sh.inc"
source "${__SHELL_CFG_ROOT}/common/editor_config.sh.inc"
source "${__SHELL_CFG_ROOT}/common/git_aliases.sh.inc"
source "${__SHELL_CFG_ROOT}/common/password_store.sh.inc"
