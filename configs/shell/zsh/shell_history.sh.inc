#!/usr/bin/env

# History configuration
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

setopt APPEND_HISTORY       # Append history to the history file (no overwriting)
setopt SHARE_HISTORY        # Share history across all sessions
setopt HIST_IGNORE_DUPS     # Don't record duplicate entries
setopt HIST_IGNORE_ALL_DUPS # Delete old recorded entry if new entry is a duplicate
setopt HIST_FIND_NO_DUPS    # Don't display duplicates when searching history
setopt HIST_SAVE_NO_DUPS    # Don't write duplicate entries to history file
setopt INC_APPEND_HISTORY   # Write to history file immediately, not when shell exits
