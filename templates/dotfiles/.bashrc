export RC_SHELL=bash

# PLUGINS
# =======

source ~/.rc

# Bash Completion
if [ -f $(brew --prefix)/etc/bash_completion ]; then
    source $(brew --prefix)/etc/bash_completion
fi


# MAIN
# ====

# Prompt
source ~/.bash_prompt

# Aliases
source ~/.aliases


# MISC
# ====

# File listings
shopt -s extglob

# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob

# Append to Bash history instead of overwriting it
shopt -s histappend

# Autocorrect typos in path names when using 'cd'
shopt -s cdspell
