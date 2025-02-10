#!/usr/bin/env false

# These includes expect my personal shell library shim to already be available. Make sure the base
# shell command, before including this one, has already sourced the shim.

# shellcheck source-path=./configs/shell

if [ -z "${__SHELL_CFG_ROOT}" ]; then
  echo "warning: the environment variable __SHELL_CFG_ROOT needs to be set before the shell library can be used" >&2
fi

## Core experience / UX

. "${__SHELL_CFG_ROOT}/common/dotfiles_path.sh.inc"

## Environment & path setup

. "${__SHELL_CFG_ROOT}/common/telemetry_opt_out.sh.inc"
. "${__SHELL_CFG_ROOT}/common/python_uv_environment.sh.inc"
. "${__SHELL_CFG_ROOT}/common/rust_cargo_environment.sh.inc"
. "${__SHELL_CFG_ROOT}/common/tfenv_setup.sh.inc"

## Convenience setup

. "${__SHELL_CFG_ROOT}/common/custom_dictionary.sh.inc"
. "${__SHELL_CFG_ROOT}/common/editor_config.sh.inc"
. "${__SHELL_CFG_ROOT}/common/git_aliases.sh.inc"
. "${__SHELL_CFG_ROOT}/common/password_store.sh.inc"
. "${__SHELL_CFG_ROOT}/common/ssh_agent_setup.sh.inc"

## Project / System / Organization environment specific setup

detected_os="$(_plc detect_os)"

if [ "${detected_os}" = "macos" ]; then
  . "${__SHELL_CFG_ROOT}/operating_systems/docker_desktop.sh.inc"

  . "${__SHELL_CFG_ROOT}/common/macosx/misc-dev-env.sh.inc"

  # Needed to provide access to Nix tooling
  . "${__SHELL_CFG_ROOT}/common/macosx/setup-nix-env.sh.inc"

  # Currently I don't have a better way to detect I'm in a Tulip environment but since this is the
  # only place I use a Mac...
  . "${__SHELL_CFG_ROOT}/environments/tulip_development.sh.inc"
fi
