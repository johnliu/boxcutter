export RC_SHELL=zsh

# Theme
DEFAULT_USER={{ ansible_env.USER }}
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context dir pyenv virtualenv vcs)
POWERLEVEL9K_INSTALLATION_PATH=$ANTIGEN_BUNDLES/{{ ansible_env.USER }}/powerlevel9kv

# Plugins
source /usr/local/share/antigen/antigen.zsh

antigen bundle mbrubeck/compleat
antigen bundle zsh-users/zsh-autosuggestions
antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle zsh-users/zsh-history-substring-search
antigen theme bhilburn/powerlevel9k powerlevel9k
antigen apply

source ~/.rc
source  ~/.aliases

# zsh-users/zsh-history-substring-search
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# Share history
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=10000
setopt extended_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_verify
setopt inc_append_history
setopt share_history
