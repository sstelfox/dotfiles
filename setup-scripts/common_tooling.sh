#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

if [ ${EUID} = 0 ]; then
	echo "This setup script is expecting to run as a regular user."
	exit 1
fi

# The initial version that will be installed from GitHub releases
PINNED_RTX_VERSION=${PINNED_RTX_VERSION:-v1.32.0}

# Whether the binary should perform a self-update after being downloaded (recommended)
UPDATE_RTX_IN_PLACE=true

function ensure_rtx_installed() {
	if [ -x $HOME/.dotfiles/in_path/bin/rtx ]; then
		return 0
	fi

	wget -O ~/.dotfiles/in_path/bin/rtx https://github.com/jdxcode/rtx/releases/download/${PINNED_RTX_VERSION}/rtx-${PINNED_RTX_VERSION}-linux-x64
	chmod +x ~/.dotfiles/in_path/bin/rtx

	if [ "${UPDATE_RTX_IN_PLACE}" = "true" ]; then
		rtx self-update
	fi
}

function install_latest_rtx_plugin() {
	local PLUGIN_NAME="${1:-}"
	local INSTALL_LATEST="${2:-n}"

	if [ -z "${PLUGIN_NAME}" ]; then
		echo 'A plugin name needs to be provided to install_latest_rtx_plugin()'
		return 1
	fi

	ensure_rtx_installed

	if ! rtx plugins ls-remote | grep -q ${PLUGIN_NAME} &>/dev/null; then
		echo "Plugin named '${PLUGIN_NAME}' is not available with RTX"
		return 2
	fi

	INSTALLER_OUTPUT="$(rtx plugin install ${PLUGIN_NAME} 2>&1)"
	if [ $? -ne 0 ]; then
		echo -e "Failed to install RTX plugin, output was:\n${INSTALLER_OUTPUT}"
		return 3
	fi

	case "${INSTALL_LATEST}" in
	[yY] | yes)
		INSTALLER_OUTPUT="$(rtx install ${PLUGIN_NAME})"
		if [ $? -ne 0 ]; then
			echo -e "Failed to install latest ${PLUGIN_NAME}, output was:\n${INSTALLER_OUTPUT}"
			return 4
		fi

		rtx use --global ${PLUGIN_NAME}
		;;
	[nN] | no)
		# Do nothing
		/bin/true
		;;
	*)
		echo "Invalid option provided to install_latest_rtx_plugin() on whether to install the latest version of ${PLUGIN_NAME}"
		return 5
		;;
	esac

	return 0
}

# TODO: These belong in the individual scripts
# TODO: Need to figure out per-project gemset settings kind of things
install_latest_rtx_plugin gcloud yes
install_latest_rtx_plugin kubectl yes
install_latest_rtx_plugin ruby yes

install_latest_rtx_plugin terraform yes
install_latest_rtx_plugin terrascan yes
