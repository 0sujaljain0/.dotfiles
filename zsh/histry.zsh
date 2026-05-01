# Where the history file is stored
HISTFILE=~/.zsh_history

# How many lines to keep in memory and on disk
HISTSIZE=10000
SAVEHIST=10000

# Critical: Append to the file rather than overwriting it
setopt APPEND_HISTORY

# Share history between different terminal windows/sessions
setopt SHARE_HISTORY

# Save timestamp and duration for each command
setopt EXTENDED_HISTORY
