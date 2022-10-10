#          _
#  _______| |__  _ __ ___
# |_  / __| '_ \| '__/ __|
#  / /\__ \ | | | | | (__
# /___|___/_| |_|_|  \___|
#


# > HELPERS {{{1
# ==============================================================================
# This section is deeply inspired by https://github.com/statico/dotfiles

# which (CSH) / whence (KSH) / where / type (Bash) / command -vV (Posix)
# ------------------------------------------------------------------------------
# command -v = whence
# command -V = whence -v
# type       = whence -v
# which      = whence -c
# where      = whence -ca

# Tests - Inside (`test` or `[]`)
# ------------------------------------------------------------------------------
# ! EXP          =>  The EXP is false.
# [ A ] && [ B ] => [ A -a B ]
# [A ] || [ B ] => [ A -o B ]
# -n STR         =>  The length of STR is greater than zero.
# -z STR         =>  The lengh of STR is zero (ie it is empty).
# STR1 = STR2    =>  STR1 is equal to STR2
# STR1 != STR2   =>  STR1 is not equal to STR2
# INT1 -eq INT2  =>  INT1 is numerically equal to INT2
# INT1 -gt INT2  =>  INT1 is numerically greater than INT2
# INT1 -lt INT2  =>  INT1 is numerically less than INT2
# -d FILE        =>  FILE exists and is a directory.
# -e FILE        =>  FILE exists.
# -f FILE        =>  FILE exists and is a regular file.
# -r FILE        =>  FILE exists and the read permission is granted.
# -s FILE        =>  FILE exists and it's size is greater than zero (ie. it is not empty).
# -w FILE        =>  FILE exists and the write permission is granted.
# -x FILE        =>  FILE exists and the execute permission is granted.

# Check if a command is executable or aliased
# ------------------------------------------------------------------------------
_has() {
  return $(command -v $1 &>/dev/null)
}

# Check if the host is of the expected type
# ------------------------------------------------------------------------------
_is() {
  return $([ "$HOSTTYPE" = "$1" ])
}

# Helpers
# ------------------------------------------------
_try_source() {
  [ -f $1 ] && . $1
}

# Helpers
# ------------------------------------------------------------------------------
_try_source_plugin() {
  _try_source $(brew --prefix)/share/$1/$1.zsh && return 0
  _try_source /usr/share/zsh/plugins/$1/$1.zsh && return 0
  echo "$1 not installed" >&2
  return 1
}

# Append a given directory to the path (only if it exists)
# ------------------------------------------------------------------------------
_append_to_path() {
  [ -d "$1" -a -z "${PATH[(r)$1]}" ] && PATH=$1:$PATH
}

# Prepend a given directory to the path (if it exists)
# ------------------------------------------------------------------------------
_prepend_to_path() {
  [ -d "$1" -a -z "${PATH[(r)$1]}" ] && PATH=$1:$PATH
}

# Prepend a given directory to the path (and remove its previous iterations)
# ------------------------------------------------------------------------------
_force_prepend_to_path() {
  [ -d "$1" ] && PATH=$1:${(@)PATH:#$1}
}


# > ENVIRONMENT VARIABLES {{{1
# ==============================================================================

# Language (Execute `locale` to see the result)
# ------------------------------------------------------------------------------
export LC_ALL=             # Reset all locale variables
export LANG="fr_FR.UTF-8"  # Set FR as default locale
export LC_MESSAGES="POSIX" # Set POSIX for commands messages

# Host
# ------------------------------------------------------------------------------
export HOSTNAME="$(uname -n)"
export HOSTTYPE="$(uname -s)"

# Ensure XDG Specs
# ------------------------------------------------------------------------------
export XDG_DATA_HOME="$HOME/.local/share" # User specific data
export XDG_CONFIG_HOME="$HOME/.config"    # User specific configuration
export XDG_CACHE_HOME="$HOME/.cache"      # User specific non-essential data

# Folders
# ------------------------------------------------------------------------------
export CODE_ROOT="$HOME/code"

# Programs
# ------------------------------------------------------------------------------
_editor() {
  if   _has nvim; then echo "nvim"
  elif _has vim;  then echo "vim"
  else                 echo "vi"
  fi
}

# export BROWSER="firefox"
export EDITOR="$(_editor)"
export FILE="ranger"
export PAGER="less"
export VISUAL="$EDITOR"


# Clean home directory
# ------------------------------------------------------------------------------
# export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
# export AWS_SHARED_CREDENTIALS_FILE="$XDG_CONFIG_HOME/aws/credentials"
# export AWS_CONFIG_FILE="$XDG_CONFIG_HOME/aws/config"
# export TMUX_TMPDIR="$XDG_CACHE_HOME/tmux/tmp"
# export BUNDLE_USER_CONFIG="$XDG_CONFIG_HOME/bundle"
# export BUNDLE_USER_CACHE="$XDG_CACHE_HOME/bundle"
# export BUNDLE_USER_PLUGIN=$XDG_DATA_HOME"/bundle"
# export GEM_HOME="$XDG_DATA_HOME/gem"
# export GEM_SPEC_CACHE="$XDG_CACHE_HOME/gem"
# export GEMRC="$XDG_CONFIG_HOME/ruby/.gemrc"
export IRBRC="$XDG_CONFIG_HOME/ruby/irbrc"
# export PASSWORD_STORE_DIR="$XDG_DATA_HOME/password-store"
# export GNUPGHOME="$XDG_DATA_HOME/gnupg"
# export MYSQL_HISTFILE="$XDG_DATA_HOME/mysql_history"
# export NODE_REPL_HISTORY="$XDG_DATA_HOME/node_repl_history"
# export PSQLRC="$XDG_CONFIG_HOME/pg/psqlrc"
# export PSQL_HISTORY="$XDG_CACHE_HOME/pg/psql_history"
# export PGPASSFILE="$XDG_CONFIG_HOME/pg/pgpass"
# export PGSERVICEFILE="$XDG_CONFIG_HOME/pg/pg_service.conf"


# History
# ------------------------------------------------------------------------------
export HISTFILE="$XDG_CACHE_HOME/zsh/history"
export HISTSIZE=10000
export SAVEHIST=10000
setopt HIST_IGNORE_ALL_DUPS # Do not overload history
setopt SHARE_HISTORY        # Share history between sessions

# ZSH options
# ------------------------------------------------------------------------------
export KEYTIMEOUT=1
unsetopt CORRECT # Stop correcting my typos
# unsetopt NOMATCH # I do not remember why I previously set it!
unsetopt AUTO_CD # Explicitely type `cd` commands

# base16-shell
# ------------------------------------------------------------------------------
# BASE16_SHELL="$XDG_CONFIG_HOME/base16-shell/"
# export BASE16_SHELL_DEFAULT_VARIANT="1"
# [ -n "$PS1" ] && \
#   [ -s "$BASE16_SHELL/profile_helper.sh" ] && \
#   eval "$("$BASE16_SHELL/profile_helper.sh")"
# _try_source "$XDG_CONFIG_HOME/base16-fzf/bash/base16-onedark.config"
source "$XDG_DATA_HOME/base16/onedark.sh"
source "$CODE_ROOT/guillaumeboudon/base16-scripts/scripts/shell.sh"

# grep
# ------------------------------------------------------------------------------
export GREP_COLOR='1;32'

# Less
# ------------------------------------------------------------------------------
[ -r "$XDG_CACHE_HOME/less/lesshst" ] && export LESSHISTFILE="$XDG_CACHE_HOME/less/lesshst"
[ -r "$XDG_CONFIG_HOME/less/lesskey" ] && export LESSKEY="$XDG_CONFIG_HOME/less/lesskey"
export LESS="-RI"
export LESS_TERMCAP_mb=$'\e[1;31m'     # begin bold
export LESS_TERMCAP_md=$'\e[1;36m'     # begin blink
export LESS_TERMCAP_me=$'\e[0m'        # reset bold/blink
export LESS_TERMCAP_so=$'\e[01;44;33m' # begin reverse video
export LESS_TERMCAP_se=$'\e[0m'        # reset reverse video
export LESS_TERMCAP_us=$'\e[1;32m'     # begin underline
export LESS_TERMCAP_ue=$'\e[0m'        # reset underline

# ls
# ------------------------------------------------------------------------------
export LS_COLORS='no=00:fi=00:di=01;34:ln=01;36:pi=33:so=01;35:bd=33;01:cd=33;01:or=01;05;37;41:mi=01;37;41:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.bz=01;31:*.tz=01;31:*.rpm=01;31:*.cpio=01;31:*.jpg=01;35:*.gif=01;35:*.bmp=01;35:*.xbm=01;35:*.xpm=01;35:*.png=01;35:*.tif=01;35:'
export LSCOLORS='ExGxFxdxCxDxDxcxcxxCxc'
export CLICOLOR=1

# GPG
# ------------------------------------------------------------------------------
export GPG_TTY=$(tty) # This is mandatory for gpg-agent to work correctly

# Ripgrep
# ------------------------------------------------------------------------------
export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/ripgrep"

# FZF
# ------------------------------------------------------------------------------
export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow --glob "!{.git,node_modules,elm-stuff}/*" 2> /dev/null'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS=" \
  --preview '(bat {} || tree -C {}) 2>/dev/null | head -200' \
  --color=fg:#$BASE16_04,bg:-1,hl:#$BASE16_0D,fg+:#$BASE16_06,bg+:#$BASE16_01,hl+:#$BASE16_08,info:#$BASE16_0A,prompt:#$BASE16_0E,pointer:#$BASE16_0C,marker:#$BASE16_0C,spinner:#$BASE16_0C,header:#$BASE16_0D \
"
_try_source ~/.fzf.zsh

# Ledger
# ------------------------------------------------------------------------------
# --strict        Warn if account, tag or commodity is unknown.
# --pedantic      Abort if account, tag or commodity is unknown.
# --check-payees  Warn/abort if payee is unknown.
# --explicit      Warn/abort also for cleared transactions
# --price-db FILE Specify the location of the price entry data file.
# --market        Report last known market value.
# --wide          Cause the default register report to assume a wide screen.
# --flat          Do not shouw accounts in a hierarchical tree
# --pager=less"
LEDGER_ARGS="--pedantic --check-payees" #--price-db prices.txt --market --explicit"
alias led="ledger -f ~/.config/ledger/main.ledger ${LEDGER_ARGS}"
alias ledp="ledger -f ~/.config/ledger/main.ledger ${LEDGER_ARGS} --pager=less"

# Rbenv & Nodenv
# ------------------------------------------------
_has nodenv && eval "$(nodenv init -)"
_has pyenv  && eval "$(pyenv init -)"
_has rbenv  && eval "$(rbenv init -)"

# watson
# ------------------------------------------------
export WATSON_DIR="$XDG_CONFIG_HOME/watson"

# youtube-dl
# ------------------------------------------------
alias yd="youtube-dl --add-metadata --continue --ignore-errors"
alias yda="yd --extract-audio --audio-format mp3 --output \"~/Downloads/youtube-dl/audio/%(channel)s/%(title)s.%(ext)s\""
alias ydv="yd --format bestvideo+bestaudio --merge-output-format mkv --output \"~/Downloads/youtube-dl/video/%(channel)s/%(title)s.%(ext)s\""
ydt() { yda "https://www.youtube.com/watch?v=$1" }
ydp() { yda "https://www.youtube.com/playlist?list=$1" }

# z
# ------------------------------------------------
export _Z_DATA="$XDG_DATA_HOME/z"
_try_source $(brew --prefix)/etc/profile.d/z.sh


# > PATH {{{1
# ==============================================================================

_force_prepend_to_path "$(brew --prefix)/opt/coreutils/libexec/gnubin"
_force_prepend_to_path "$HOME/.local/bin"


# > ALIASES {{{1
# ==============================================================================

# Overrides
# ------------------------------------------------------------------------------
alias c="bundle exec cucumber"
alias ct="c --tags"

alias g="git"

alias ls="gls -v  --color=auto --group-directories-first --classify"
alias ll="ls -l --human-readable"

alias m="cmus"
alias mn="cmus-remote -n"   # Next
alias mp="cmus-remote -r"   # Previous
alias mq="cmus-remote -C q" # Quit cmus
alias ms="cmus-remote -s"   # Stop
alias mst="cmus-remote -Q"   # Status
alias mt="cmus-remote -u"   # Toggle play/pause
alias mz="cmus-remote -S"   # Shuffle

alias v="nvim"
alias vimdiff="nvim -d"
alias vi="$(brew --prefix)/bin/vim"

alias tmux="tmux -f $XDG_CONFIG_HOME/tmux/tmux.conf"
alias mux="tmuxinator"

alias w="watson"

alias bx="bundle exec"

# Scripts
# ------------------------------------------------------------------------------
alias show='defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder'
alias hide='defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder'
alias weather='curl fr.wttr.in/Gallardon'
alias wth="curl \"fr.wttr.in/Gallardon?format='%l:+%c+%t'\""
alias my_ip="curl ipecho.net/plain; echo"

my_mac() {
  networksetup -listallhardwareports
    # grep Wi-Fi -A 3 | \
    # awk '/Ethernet Address:/{print $3}'
}


# > FUNCTIONS {{{1
# ==============================================================================

# mkdir + cd
# ------------------------------------------------------------------------------
take() {
  mkdir -p -- "$1" && cd -P -- "$1"
}

# Send translation to clipboard
# ------------------------------------------------------------------------------
if _has trans; then
  translate() {
    trans -b "$2" "$1" | tr -d '\n' | pbcopy
  }
fi


# > COMPLETION {{{1
# ==============================================================================

autoload -U compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zmodload zsh/complist
compinit -i -d "$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"
_comp_options+=(globdots) # Include hidden files


# > KEYBINDINGS {{{1
# ==============================================================================

# Mode vim
# ------------------------------------------------------------------------------
bindkey -v

bindkey -a c vi-backward-char
bindkey -a r vi-forward-char
bindkey -a t vi-down-line-or-history
bindkey -a s vi-up-line-or-history
bindkey -a $ vi-end-of-line
bindkey -a 0 vi-digit-or-beginning-of-line
bindkey -a l vi-change
bindkey -a L vi-change-eol
bindkey -a dd vi-change-whole-line
bindkey -a h vi-replace-chars
bindkey -a H vi-replace
bindkey -a k vi-substitute
bindkey '^?' backward-delete-char
bindkey -a '^?' vi-backward-char
bindkey '^h' backward-delete-char
bindkey '^[[3~' delete-char
bindkey -a '^[[3~' vi-forward-char
bindkey '^a' beginning-of-line
bindkey -a '^a' beginning-of-line
bindkey '^e' end-of-line
bindkey -a '^e' end-of-line
# Edit line in vim with ctrl-e:
autoload edit-command-line; zle -N edit-command-line
bindkey '^t' edit-command-line
bindkey -a '^t' edit-command-line

# Use vim keys in tab complete menu:
# ------------------------------------------------------------------------------
bindkey -M menuselect 'c' vi-backward-char
bindkey -M menuselect 's' vi-up-line-or-history
bindkey -M menuselect 'r' vi-forward-char
bindkey -M menuselect 't' vi-down-line-or-history
bindkey -v '^?' backward-delete-char

# Change cursor shape for different vi modes.
# ------------------------------------------------------------------------------
function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] ||
    [[ $1 = 'block' ]]; then
      echo -ne '\e[1 q'
    elif [[ ${KEYMAP} == main ]] ||
      [[ ${KEYMAP} == viins ]] ||
      [[ ${KEYMAP} = '' ]] ||
      [[ $1 = 'beam' ]]; then
          echo -ne '\e[5 q'
  fi
}
zle -N zle-keymap-select
zle-line-init() {
zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
echo -ne "\e[5 q"
}
zle -N zle-line-init
echo -ne '\e[5 q' # Use beam shape cursor on startup.
preexec() { echo -ne '\e[5 q' ;} # Use beam shape cursor for each new prompt.


# > PLUGINS {{{1
# ==============================================================================

# Autosuggestions
# ------------------------------------------------
_try_source_plugin zsh-autosuggestions
# ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=23'

# Syntax highlighting
# ------------------------------------------------
_try_source_plugin zsh-syntax-highlighting

# History substring search
# ------------------------------------------------
_try_source_plugin zsh-history-substring-search
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
export HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='bg=green,fg=black,bold'
export HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND='bg=yellow,fg=white,bold'
export HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=true
export HISTORY_SUBSTRING_SEARCH_FUZZY=true

# > PROMPT {{{1
# ==============================================================================

#autoload -U colors && colors
#autoload -Uz vcs_info
#
#precmd() { vcs_info }
#setopt PROMPT_SUBST
#shorten_pwd() { echo $PWD | sed -e "s;$HOME;~;" -e "s;\(\.*[^/]\)[^/]*/;\1/;g" }
#
#zstyle ':vcs_info:git:*' formats '%F{black}%K{green}  %b %k%f'
#zstyle ':vcs_info:git:*' actionformats '%F{black}%K{green}  %b %k%f'
#PROMPT='%F{yellow}%K{10}%n@%m %k%f'
#PROMPT+='%F{10}%K{blue}%k%f'
#PROMPT+='%F{black}%K{blue} $(shorten_pwd) %k%f'
#PROMPT+='%F{blue}%K{green}%k%f'
#PROMPT+='${vcs_info_msg_0_}'
#PROMPT+='%F{green}%f '
eval "$(starship init zsh)"

# > LOCAL CONFIG {{{1
# ==============================================================================

_try_source "$XDG_CONFIG_HOME/zsh/local.zsh"

# }}}

# Return value
true
