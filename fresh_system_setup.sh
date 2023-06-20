#!/bin/bash

set -o errexit

if [ ${EUID} = 0 ]; then
	echo "This setup script should only be run in the context of the primary user."
	exit 1
fi

source /etc/os-release

if [ "${NAME}" != "Fedora" -a "${NAME}" != "Fedora Linux" ]; then
	echo "These setup scripts are only targetting Fedora. It looks like you're trying to run this on another distro."
	exit 1
fi

ROOT_SCRIPTS=('base_root_setup.sh')
USER_SCRIPTS=('base_user_setup.sh')

function ask_default_no() {
	local prompt="${1}"

	read -p "${prompt} [N/y] " response
	case "${response}" in
	[nN])
		return 1
		;;
	[yY])
		return 0
		;;
	*)
		return 1
		;;
	esac
}

function ask_default_yes() {
	local prompt="${1}"

	read -p "${prompt} [n/Y] " response
	case "${response}" in
	[nN])
		return 1
		;;
	[yY])
		return 0
		;;
	*)
		return 0
		;;
	esac
}

if ask_default_yes 'Would you like to setup the system to be a desktop?'; then
	ROOT_SCRIPTS+=('desktop_root.sh')
	USER_SCRIPTS+=('desktop_user.sh')
	export DESKTOP_ENABLED="y"
fi

if ask_default_no 'Would you like to setup nftables as the firewall?'; then
	ROOT_SCRIPTS+=('nftables.sh')
	export NFTABLES_ENABLED="y"
fi

if ask_default_yes 'Would you like to setup Rust?'; then
	USER_SCRIPTS+=('rust.sh')
fi

if ask_default_no 'Would you like to setup Ruby?'; then
	ROOT_SCRIPTS+=('ruby_dependencies.sh')
	USER_SCRIPTS+=('ruby.sh')
fi

if ask_default_no 'Would you like to install Yarn?'; then
	ROOT_SCRIPTS+=('yarn.sh')
fi

if ask_default_no 'Would you like to install ansible?'; then
	ROOT_SCRIPTS+=('ansible.sh')
fi

if ask_default_yes 'Would you like to install podman?'; then
	ROOT_SCRIPTS+=('podman.sh')
fi

if ask_default_no 'Would you like to install kubernetes tooling?'; then
	ROOT_SCRIPTS+=('k8s.sh')
fi

if ask_default_yes 'Would you like to support running hardware virtual machines?'; then
	if [ "${NFTABLES_ENABLED}" = "y" ]; then
		echo "WARNING: NFTables may break virtualization guests"
	fi

	ROOT_SCRIPTS+=('virtualization.sh')
fi

# These questions only make sense if I enabled the desktop questions
if [ "${DESKTOP_ENABLED}" = "y" ]; then
	if ask_default_yes 'Would you like to install the art packages?'; then
		ROOT_SCRIPTS+=('art_packages.sh')
	fi

	if ask_default_no 'Would you also like to install nvidia drivers?'; then
		ROOT_SCRIPTS+=('nvidia_drivers.sh')
		export RPM_FUSION_REQUIRED="y"
	fi

	if ask_default_no 'Would you also like to install the game development packages?'; then
		ROOT_SCRIPTS+=('game_development.sh')
		export GAME_DEVELOPMENT="y"
	fi

	if ask_default_no 'Would you like to install the embedded/electronic design tools?'; then
		ROOT_SCRIPTS+=('embedded_development.sh')
		export EMBEDDED_DEVELOPMENT="y"
	fi

	if ask_default_no 'Would you like to install the gaming packages?'; then
		ROOT_SCRIPTS+=('gaming.sh')
	fi

	if ask_default_no 'Would you like to install the streaming packages?'; then
		ROOT_SCRIPTS+=('streaming.sh')
	fi
fi

echo

echo "I'm going to run the following root scripts:"
for script in ${ROOT_SCRIPTS[*]}; do
	echo -e "\t* ${script}"
done
echo

if [ ${#USER_SCRIPTS[@]} -gt 0 ]; then
	echo "...and the following user scripts: ${USER_SCRIPTS[*]}"
	for script in ${USER_SCRIPTS[*]}; do
		echo -e "\t* ${script}"
	done
	echo
fi

if ask_default_no 'Are you ready to do this?'; then
	# Start by testing / prompting for root permissions, will abort if the user
	# Ctrl-C's out of this request
	sudo echo -n

	export SETUP_USER=$(whoami)

	# Build a singular root script so we don't have to worry about sudo timing
	# out half way through
	echo -e '#!/bin/bash\n\n' >/tmp/setup_script.sh

	if [ "${RPM_FUSION_REQUIRED:-}" = "y" ]; then
		cat ~/.dotfiles/setup-scripts/rpm_fusion.sh >>/tmp/setup_script.sh
	fi

	for script in ${ROOT_SCRIPTS[*]}; do
		cat ~/.dotfiles/setup-scripts/${script} >>/tmp/setup_script.sh
	done

	# Have the script clean itself up
	echo -e '\nrm ${0}' >>/tmp/setup_script.sh

	sudo /bin/bash /tmp/setup_script.sh

	# For user scripts we can just run them directly as we don't have to worry
	# about timeouts on sudo sessions.
	for script in ${USER_SCRIPTS[*]}; do
		~/.dotfiles/setup-scripts/${script}
	done
fi
