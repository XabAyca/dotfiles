# Setup fzf
# ---------
if [[ ! "$PATH" == */Users/xabi/.fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}/Users/xabi/.fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "/Users/xabi/.fzf/shell/completion.zsh" 2> /dev/null

# Key bindings
# ------------
source "/Users/xabi/.fzf/shell/key-bindings.zsh"
