# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Language (Execute `locale` to see the result)
# ------------------------------------------------------------------------------
export LC_ALL=             # Reset all locale variables
export LANG="fr_FR.UTF-8"  # Set FR as default locale
export LC_MESSAGES="POSIX" # Set POSIX for commands messages

export ZSH="$HOME/.oh-my-zsh"

source ~/.local/share/p10k/powerlevel10k.zsh-theme
source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
plugins=(git ruby fzf-tab)
source $ZSH/oh-my-zsh.sh
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# fzf-tab : preview du dossier sur `cd <Tab>` (le reste hérite de FZF_DEFAULT_OPTS)
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'lsd -1 --color=always $realpath'

export EDITOR='nvim'

ZLE_RPROMPT_INDENT=0

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

export PATH="$HOME/.local/bin:$PATH"

# mise : gestionnaire de runtimes du serveur. Indispensable, les binaires installes
# par mise (node, claude, ...) ne sont pas dans le PATH sans cette activation.
eval "$(mise activate zsh)"

# FZF : intégration officielle (keybindings Ctrl-T/Ctrl-R/Alt-C + completion)
export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --preview-window=right:50%'
export FZF_CTRL_T_OPTS="--preview 'bat --style=numbers --color=always --line-range :200 {}'"
eval "$(fzf --zsh)"

alias ll="lsd --git --ignore-glob='*DS_Store*' -l --group-directories-first --truncate-owner-after 0"
alias ll2="lsd --tree --depth 2 --git --ignore-glob='*DS_Store*' -l --group-directories-first --truncate-owner-after 0"
alias t="tmux new-session -A -s"
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
