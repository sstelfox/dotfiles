set -o errexit

if [ ${EUID} = 0 ]; then
	echo "This setup script is expecting to run as a regular user."
	exit 1
fi

balooctl6 suspend
balooctl6 disable
balooctl6 purge
