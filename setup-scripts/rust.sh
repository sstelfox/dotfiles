#!/bin/bash

set -o errexit

if [ ${EUID} = 0 ]; then
  echo "This setup script is expecting to run as a regular user."
  exit 1
fi

if [ ! -f $HOME/.cargo/env ]; then
  curl https://sh.rustup.rs -sSf | sh -s -- --no-modify-path --default-toolchain nightly -y
fi

source $HOME/.cargo/env

rustup component add rustfmt
rustup component add clippy
rustup install stable

cargo install cargo-audit

if [ "${EMBEDDED_DEVELOPMENT}" = "y" ]; then
  rustup target add --toolchain stable thumbv6m-none-eabi
  rustup target add --toolchain nightly thumbv6m-none-eabi

  cargo install cargo-binutils itm
  rustup component add llvm-tools-preview
fi
