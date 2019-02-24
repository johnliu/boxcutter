export RC_SHELL=zsh

# Theme
DEFAULT_USER={{ ansible_env.USER }}
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
