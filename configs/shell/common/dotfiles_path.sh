#!/usr/bin/env false

# Prepend scripts and binaries from my dotfiles to the path so they can take precedence over things
# installed system-wide.
export PATH="${__DOTFILE_ROOT}/in_path/bin:${__DOTFILE_ROOT}/in_path/scripts:${PATH}"
