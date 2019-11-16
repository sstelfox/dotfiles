#!/bin/bash

source _root_prelude.sh

if [ ! -f $HOME/.cargo/env ]; then
  curl https://sh.rustup.rs -sSf | sh -s -- --no-modify-path --default-toolchain nightly -y
fi

source $HOME/.cargo/env

rustup component add rustfmt
rustup install stable
