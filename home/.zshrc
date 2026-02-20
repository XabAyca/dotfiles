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
plugins=(git ruby macos fzf)
source $ZSH/oh-my-zsh.sh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

export EDITOR='nvim'
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES

ZLE_RPROMPT_INDENT=0

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

eval "$(pyenv init -)"
eval "$(nodenv init -)"
eval "$(rbenv init -)"

alias ll="lsd --git --ignore-glob='*DS_Store*' -l --group-directories-first --truncate-owner-after 0"
alias ll2="lsd --tree --depth 2 --git --ignore-glob='*DS_Store*' -l --group-directories-first --truncate-owner-after 0"
alias tpro="tmuxinator start pro"
alias t="tmux new-session -A -s"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
