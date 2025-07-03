#!/bin/bash

set -o errexit

if [ ${EUID} = 0 ]; then
  echo "This setup script is expecting to run as a regular user."
  exit 1
fi

if ! which cmake &>/dev/null; then
  echo 'cmake is needed for some rust dependencies to be built'
  exit 1
fi

if [ ! -f $HOME/.cargo/env ]; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs |
    sh -s -- --no-modify-path --default-toolchain nightly -y
fi

source $HOME/.cargo/env

rustup component add rust-analyzer
rustup component add rustfmt
rustup component add clippy

rustup install stable

# Viu is a sweet terminal image viewer that is super handy
cargo install cargo-audit cargo-deny viu

mkdir -p ~/workspace/rust
