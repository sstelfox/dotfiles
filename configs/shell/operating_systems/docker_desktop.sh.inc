#!/usr/bin/env false

if [ -d "${HOME}/.docker/bin" ]; then
  # Intentionally putting this at the end of the path. I prefer my system installed binaries when
  # available but I don't use docker on any other OS. I very much do not want the docker version
  # of some utilities like kubectl.
  export PATH="${PATH}:${HOME}/.docker/bin"
fi
