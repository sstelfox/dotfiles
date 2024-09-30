#!/usr/bin/env false

# Hidden environment variable to disable telemetry tracking in the Azure CLI
export AZURE_CORE_COLLECT_TELEMETRY=0

# Likely not adopted by anyone, but for the apps that do I definitely want to opt-out
# https://consoledonottrack.com/
export DO_NOT_TRACK=1
