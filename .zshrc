#Starship
eval "$(starship init zsh)"

# Activate syntax highlighting
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Disable underline
(( ${+ZSH_HIGHLIGHT_STYLES} )) || typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[path]=none
ZSH_HIGHLIGHT_STYLES[path_prefix]=none

# Activate autosuggestions
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

alias home='cd ~/'


# Vim alias
alias vim=nvim
alias vim_s='NVIM_APPNAME=nvim-snacks nvim'
alias vim_m='NVIM_APPNAME=nvim-mini nvim'
alias vim2='NVIM_APPNAME=nvim_2 nvim'
alias vim3='NVIM_APPNAME=nvim_3 nvim'


alias conlab="sshpass -p 'Spidse82!' ssh admin@172.16.1.90"

