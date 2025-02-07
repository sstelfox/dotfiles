#!/usr/bin/env sh

set -o errexit
set -o nounset

vnix ./inner-build.sh test-container
