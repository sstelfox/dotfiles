#!/bin/bash

set -o errexit

if [ ${EUID} = 0 ]; then
	echo "This setup script is expecting to run as a regular user."
	exit 1
fi

if [ ! -f $HOME/.cargo/env ]; then
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --no-modify-path --default-toolchain nightly -y
fi

source $HOME/.cargo/env

rustup component add rust-analyzer
rustup component add rustfmt
rustup component add rust-src
rustup component add clippy
rustup component add miri

rustup target add wasm32-unknown-unknown

rustup install stable

# Viu is a sweet terminal image viewer that is super handy
cargo install cargo-audit cargo-deny starship trunk viu wasm-pack

# To use: `export RUSTC_WRAPPER=sccache`
#cargo install sccache

if [ "${EMBEDDED_DEVELOPMENT}" = "y" ]; then
	rustup target add --toolchain stable thumbv6m-none-eabi
	rustup target add --toolchain nightly thumbv6m-none-eabi

	cargo install cargo-binutils itm
	rustup component add llvm-tools-preview
fi

mkdir -p ~/workspace/rust
