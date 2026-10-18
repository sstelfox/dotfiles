#!/usr/bin/env false

# Workaround new and shitty behavior that doesn't have an opt-out. It will auto-continue on prompts
# without the user having a chance to respond. The "feature" can't be disabled (github ticket #73408)
# the only way to mitigate this behavioral regression is to set a very high timeout.
export CLAUDE_AFK_TIMEOUT_MS=2147483647

# This causes wayyyy too many problems. It's weird hidden state that lives outside of the repository
# and holds contradictory information in ways that aren't transparent.
export CLAUDE_CODE_DISABLE_AUTO_MEMORY=1
