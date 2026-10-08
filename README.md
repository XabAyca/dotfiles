# :floppy_disk: dotfiles

## Install

1. Clone this repository:
    ```shell
    cd
    git clone https://github.com/XabAyca/dotfiles .dotfiles
    cd .dotfiles
    ```
2. Install Homebrew from https://brew.sh/
3. Install applications: `brew bundle`
4. Install Iterm2 config Settings > Settings > Import
5. Set dotfiles: `stow --no-folding home`
6. Install ruby:
    ```shell
    rbenv install <version>
    rbenv global <version>
    ```
    Install Python:
    ```shell
    pyenv install <version>
    pyenv global <version>
    ```
    Install Node
    ```shell
    node install <version>
    node global <version>
    ```
7. Install VSCode extensions
    ```shell
    sh install-vscode-extensions.sh
    ```
    Get extensions list:
    ```shell
    code --list-extensions
    ```
8. Install MacOs Settings
    ```shell
    source install-macos-settings.sh
    ```

## Install on a Debian/Ubuntu server (headless, SSH)

Uses the `home-forge` stow package instead of `home` (patched paths, tmux configured
to survive SSH disconnects and not leak the remote clipboard). Verified on Ubuntu 26.04.

Prerequisite: [mise](https://mise.jdx.dev) manages the runtimes and `.zshrc` activates it.
Step 2 is the only one performed on the client machine, not the server.

1. Packages. `git`, `tmux`, `fzf` and `ripgrep` are often already installed.

    ```shell
    sudo apt update
    sudo apt install -y stow zsh neovim fd-find bat lsd git-delta \
      zsh-autosuggestions zsh-syntax-highlighting
    sudo locale-gen fr_FR.UTF-8 && sudo update-locale
    ```

2. On the machine you connect **from**, install [MesloLGS NF](https://github.com/romkatv/powerlevel10k#manual-font-installation)
   and select it in the terminal. Glyphs are drawn by the client, so nothing installed
   on the server can fix missing ones. `.p10k.zsh` runs in `nerdfont-complete` mode —
   a Nerd Fonts v3 face renders shifted glyphs rather than none.

3. Dotfiles. A `~/.zshrc` or `~/.gitconfig` already in place would block stow:

    ```shell
    git clone https://github.com/XabAyca/dotfiles ~/.dotfiles
    cd ~/.dotfiles
    stow -n -v --no-folding home-forge          # dry run, writes nothing
    rm -f ~/.zshrc ~/.gitconfig
    stow --no-folding home-forge
    ```

    Add `-t ~` when the repository lives anywhere other than directly under `$HOME`.

    `~/.claude/CLAUDE.md` ships with the package: the baseline rules every agent reads,
    in every project. Claude Code picks it up on its own; other agents look for
    `AGENTS.md`, so point one at it:

    ```shell
    ln -sfn .claude/CLAUDE.md ~/AGENTS.md
    ```

4. Test before switching shells. Keep **two** SSH sessions open and, in one of them,
   run `zsh -l` — a child process you leave with `exit`, never `source ~/.zshrc`,
   which asks bash to read zsh. Check the p10k prompt and its glyphs, `node -v` and
   `which claude` (the mise test), `git diff` rendered by delta, `git log` with its
   gitmoji, `Ctrl-T` / `Ctrl-R` / `Alt-C`, `cd <Tab>`, `ll`, `nvim`, and `C-hjkl`
   across tmux panes and nvim splits.

5. Only once that is reliable, several sessions in a row:

    ```shell
    chsh -s "$(which zsh)"
    ```

    Open a **new** SSH connection and confirm it reaches the prompt before closing the
    others. Roll back from a live session with `chsh -s /bin/bash`.

Tests. The scripts of `home-forge` carry their own — no framework, no network:

```shell
find home-forge -name '*.test.sh' | while read -r t; do echo "== $t"; bash "$t" || break; done
```

Optional:

- `zdiff3` instead of `diff3` for `merge.conflictstyle`, and `syntax-theme = gruvbox-dark`
  under `[delta]` — check the name against `delta --list-syntax-themes` first.
