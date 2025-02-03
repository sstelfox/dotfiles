#!/usr/bin/env false

# Silly Golang and your weird enforced paths that no one likes... Gotta override it for this
# environment unfortunately...
export GOPATH="${HOME}/workspace/tulip/tulip/environments/cloud/services"

# This may have been my issues with the tulip dev environment, didn't find this anywhere in our
# docs but there was a passing reference to it in the diagostics of a different engineer's dev
# environment.
source "${HOME}/workspace/tulip/tulip/scripts/setPaths.source.sh"
