#!/usr/bin/env sh

set -o errexit
set -o nounset

vnix ./direct-build.sh test-container
