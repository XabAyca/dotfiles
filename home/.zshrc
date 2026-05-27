eval $(/opt/homebrew/bin/brew shellenv)
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

source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
plugins=(git ruby macos fzf-tab)
source $ZSH/oh-my-zsh.sh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# fzf-tab : preview du dossier sur `cd <Tab>` (le reste hérite de FZF_DEFAULT_OPTS)
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'lsd -1 --color=always $realpath'

export EDITOR='nvim'
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES

ZLE_RPROMPT_INDENT=0

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Lazy-load des version managers : on garde les shims en PATH pour que ruby/python/node
# fonctionnent immédiatement, et on retarde le coûteux `init -` à la première invocation
# explicite de rbenv/pyenv/nodenv (économise 30-150ms par démarrage de shell).
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$HOME/.local/bin:$PATH"
export PATH="$HOME/.rbenv/shims:$HOME/.pyenv/shims:$HOME/.nodenv/shims:$PATH"

_lazy_rbenv()  { unset -f _lazy_rbenv rbenv;   eval "$(command rbenv init -)";  rbenv "$@" }
_lazy_pyenv()  { unset -f _lazy_pyenv pyenv;   eval "$(command pyenv init -)";  pyenv "$@" }
_lazy_nodenv() { unset -f _lazy_nodenv nodenv; eval "$(command nodenv init -)"; nodenv "$@" }
rbenv()  { _lazy_rbenv  "$@" }
pyenv()  { _lazy_pyenv  "$@" }
nodenv() { _lazy_nodenv "$@" }

# FZF : intégration officielle (keybindings Ctrl-T/Ctrl-R/Alt-C + completion)
export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --preview-window=right:50%'
export FZF_CTRL_T_OPTS="--preview 'bat --style=numbers --color=always --line-range :200 {}'"
eval "$(fzf --zsh)"

alias ll="lsd --git --ignore-glob='*DS_Store*' -l --group-directories-first --truncate-owner-after 0"
alias ll2="lsd --tree --depth 2 --git --ignore-glob='*DS_Store*' -l --group-directories-first --truncate-owner-after 0"
alias tpro="tmuxinator start pro"
alias t="tmux new-session -A -s"
. "$HOME/.cargo/env"
