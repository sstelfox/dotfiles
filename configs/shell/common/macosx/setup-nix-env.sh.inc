#!/usr/bin/env false

# On MacOS since I'm not using the global shell profile I need to explicitly add this to my path.
#
# TODO(sstelfox): should ensure the path isn't present before adding... Should probably make that a
# lib tool...
export PATH="${PATH}:/nix/var/nix/profiles/default/bin"
