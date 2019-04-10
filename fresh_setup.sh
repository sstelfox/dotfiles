#!/bin/bash

sudo dnf install \
  https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y

sudo dnf copr enable @kicad/kicad -y

sudo dnf remove vim-powerline -y

sudo dnf install arm-none-eabi-gdb awscli docker docker-compose fswebcam \
  httpd-tools gdb gimp gimp-lqr-plugin gimp-save-for-web git git-email \
  gnupg2-smime golang graphviz jq kicad kicad-packages3d mutt nmap openocd \
  pcsc-lite-ccid privoxy pv tcpdump tmux tor transmission-gtk v8 vim-enhanced \
  vlc wireshark -y

# Get rid of powerline but leave vim
sudo dnf remove vim-powerline --noautoremove

sudo systemctl start pcscd.service
sudo systemctl enable pcscd.service

sudo systemctl enable sshd.service
sudo systemctl start sshd.service

sudo groupadd -r docker
sudo usermod -aG dialout,docker $(whoami)

cat << 'EOF' | sudo tee /etc/udev/rules.d/99-st-link.rules > /dev/null
# ST-LINK/V2
ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3748", MODE:="0660", OWNER="root", GROUP="dialout"

# ST-LINK/V2.1
ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374b", MODE:="0660", OWNER="root", GROUP="dialout"
EOF

sudo udevadm control --reload-rules

curl https://sh.rustup.rs -sSf | sh -s -- --no-modify-path --default-toolchain nightly -y

rustup component add rustfmt
rustup install stable
rustup target add --toolchain stable thumbv6m-none-eabi
rustup target add --toolchain nightly thumbv6m-none-eabi

cargo install cargo-binutils itm
rustup component add llvm-tools-preview

# Install and setup GEF
pip3 install --user unicorn capstone ropper keystone-engine
wget -q -O- https://github.com/hugsy/gef/raw/master/scripts/gef.sh | sh

# RVM gpg key
gpg2 --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
curl -sSL https://get.rvm.io | bash -s stable

~/.dotfiles/install
source ~/.bashrc

sudo dnf install patch autoconf automake bison fftw-devel gcc-c++ \
  libcurl-devel libffi-devel libtool libyaml-devel openssl-devel patch \
  postgresql-devel readline-devel sqlite-devel zlib-devel -y

rvm install ruby-2.6.2

echo 'You probably still need a reboot...'

#sudo systemctl disable firewalld.service
#sudo systemctl mask firewalld.service
#
#cat << 'EOF' | sudo tee /etc/sysconfig/nftables.conf
#flush ruleset
#
#table inet filter {
#  chain input {
#    type filter hook input priority 0; policy drop;
#
#    ct state invalid drop
#    ct state established,related accept
#    iif "lo" accept
#
#    ip protocol icmp accept
#    ip6 nexthdr icmpv6 accept
#
#    tcp dport 22 accept
#
#    ip protocol tcp tcp dport 67 tcp sport 68 accept
#
#    counter
#  }
#
#  chain forward {
#    type filter hook forward priority 0; policy drop;
#  }
#
#  chain output {
#    type filter hook output priority 0; policy drop;
#
#    ct state established,related accept
#    oif "lo" accept
#
#    ip protocol icmp accept
#    ip6 nexthdr icmpv6 accept
#
#    tcp dport 67 tcp sport 68 accept
#    tcp dport { 22, 53, 80, 443, 873, 2200 } accept
#    udp dport 53 accept
#
#    ct state new log level warn prefix "egress attempt: "
#    counter reject with icmp type admin-prohibited
#  }
#}
#EOF
#
#sudo systemctl enable nftables.service
#sudo systemctl start nftables.service
