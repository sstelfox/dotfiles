#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

if [ ${EUID} = 0 ]; then
	echo "This setup script is expecting to run as a regular user."
	exit 1
fi

if ! which unzip &>/dev/null; then
	# Needed by mise to download and unpack things
	echo 'unzip needs to be available to run this script'
	exit 1
fi

# The initial version that will be installed from GitHub releases
PINNED_MISE_VERSION=${PINNED_MISE_VERSION:-v2024.1.30}

# Whether the binary should perform a self-update after being downloaded (recommended)
UPDATE_MISE_IN_PLACE=true

function ensure_mise_installed() {
	if [ -x $HOME/.dotfiles/in_path/bin/mise ]; then
		return 0
	fi

	wget -O ~/.dotfiles/in_path/bin/mise https://github.com/jdx/mise/releases/download/${PINNED_MISE_VERSION}/mise-${PINNED_MISE_VERSION}-linux-x64
	chmod +x ~/.dotfiles/in_path/bin/mise

	if [ "${UPDATE_MISE_IN_PLACE}" = "true" ]; then
		~/.dotfiles/in_path/bin/mise self-update
	fi
}

function install_latest_mise_plugin() {
	local PLUGIN_NAME="${1:-}"
	local INSTALL_LATEST="${2:-n}"

	if [ -z "${PLUGIN_NAME}" ]; then
		echo 'A plugin name needs to be provided to install_latest_mise_plugin()'
		return 1
	fi

	ensure_mise_installed

	if ! ~/.dotfiles/in_path/bin/mise plugins ls-remote | grep -q ${PLUGIN_NAME} &>/dev/null; then
		echo "Plugin named '${PLUGIN_NAME}' is not available with MISE"
		return 2
	fi

	INSTALLER_OUTPUT="$(~/.dotfiles/in_path/bin/mise plugin install ${PLUGIN_NAME} 2>&1)"
	if [ $? -ne 0 ]; then
		echo -e "Failed to install MISE plugin, output was:\n${INSTALLER_OUTPUT}"
		return 3
	fi

	case "${INSTALL_LATEST}" in
	[yY] | yes)
		INSTALLER_OUTPUT="$(~/.dotfiles/in_path/bin/mise install ${PLUGIN_NAME})"
		if [ $? -ne 0 ]; then
			echo -e "Failed to install latest ${PLUGIN_NAME}, output was:\n${INSTALLER_OUTPUT}"
			return 4
		fi

		~/.dotfiles/in_path/bin/mise use --global ${PLUGIN_NAME}
		;;
	[nN] | no)
		# Do nothing
		/bin/true
		;;
	*)
		echo "Invalid option provided to install_latest_mise_plugin() on whether to install the latest version of ${PLUGIN_NAME}"
		return 5
		;;
	esac

	return 0
}

# TODO: These belong in the individual scripts
install_latest_mise_plugin gcloud yes
install_latest_mise_plugin kubectl yes
install_latest_mise_plugin terraform yes
