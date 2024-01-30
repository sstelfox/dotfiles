#!/bin/bash

set -o errexit

if [ ${EUID} = 0 ]; then
	echo "This setup script is expecting to run as a regular user."
	exit 1
fi

if [ ! -d ~/.miniconda3 ]; then
	mkdir -p ~/.miniconda3

	wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/.miniconda3/miniconda.sh

	bash ~/.miniconda3/miniconda.sh -b -u -p ~/.miniconda3
	rm -f ~/.miniconda3/miniconda.sh
fi

source ~/.miniconda3/bin/activate
conda init --all
conda update --yes --quiet conda

conda create -n default -y python

# conda activate default
# conda deactivate
