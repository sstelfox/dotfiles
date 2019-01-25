#!/bin/bash

sudo dnf install \
  https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

sudo dnf copr enable @kicad/kicad -y

sudo dnf install awscli discord docker docker-compose fswebcam gdb git \
  gnupg2-smime golang graphviz jq kicad kicad-packages3d mutt nmap \
  pcsc-lite-ccid privoxy pv tcpdump tmux tor transmission-gtk v8 vim-enhanced \
  vlc wireshark-gnome

sudo systemctl start pcscd.service
sudo systemctl enable pcscd.service

curl https://sh.rustup.rs -sSf | sh
rustup install nightly
rustup default nightly

curl -sSL https://get.rvm.io | bash -s stable
source ~/.bashrc

rvm install ruby-2.5.3
