# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Locale française, mais messages des commandes en anglais (cherchables)
unset LC_ALL
export LANG="fr_FR.UTF-8"
export LC_MESSAGES="POSIX"

export EDITOR="nvim"

HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=10000
setopt extended_history hist_expire_dups_first hist_ignore_dups hist_ignore_space hist_verify share_history
setopt auto_cd auto_pushd pushd_ignore_dups pushd_minus interactive_comments long_list_jobs
setopt complete_in_word always_to_end no_flow_control

# Flèches haut/bas : historique filtré par le début de la ligne déjà tapée
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey -e
bindkey '^[[A' up-line-or-beginning-search '^[OA' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search '^[OB' down-line-or-beginning-search
bindkey "${terminfo[khome]}" beginning-of-line "${terminfo[kend]}" end-of-line
bindkey "${terminfo[kdch1]}" delete-char

# -U : un shell lancé dans tmux hérite du PATH, sans dédoublonnage il s'allonge
typeset -U path
path=(~/.cargo/bin ~/.local/bin $path)

# Sans cette activation, les binaires installés par mise (node, claude…) sont hors du PATH
eval "$(mise activate zsh)"

autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'r:|=*' 'l:|=*'

[[ -d ~/.local/share/p10k ]] || git clone -q --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.local/share/p10k
source ~/.local/share/p10k/powerlevel10k.zsh-theme
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
ZLE_RPROMPT_INDENT=0

[[ -d ~/.local/share/fzf-tab ]] || git clone -q --depth=1 https://github.com/Aloxaf/fzf-tab ~/.local/share/fzf-tab
source ~/.local/share/fzf-tab/fzf-tab.plugin.zsh
# fzf-tab : preview du dossier sur `cd <Tab>` (le reste hérite de FZF_DEFAULT_OPTS)
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'lsd -1 --color=always $realpath'

# FZF : intégration officielle (keybindings Ctrl-T/Ctrl-R/Alt-C + completion)
export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --preview-window=right:50%'
export FZF_CTRL_T_OPTS="--preview 'bat --style=numbers --color=always --line-range :200 {}'"
eval "$(fzf --zsh)"

alias ll="lsd --git --ignore-glob='*DS_Store*' -l --group-directories-first --truncate-owner-after 0"
alias ll2="ll --tree --depth 2"
alias t="tmux new-session -A -s"

# Sa doc demande que zsh-syntax-highlighting soit sourcé en dernier
source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
