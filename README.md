# :floppy_disk: dotfiles

## Install

1. Clone this repository:
    ```shell
    cd
    git clone https://github.com/XabAyca/dotfiles .dotfiles
    cd .dotfiles
    ```
2. Install Homebrew from https://brew.sh/
3. Install OhMyZSH
    ```shell
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    ```
4. Install applications: `brew bundle`
5. Install Iterm2 config Settings > Settings > Import
6. Set dotfiles: `stow --no-folding home`
7. Run: install tmux plugins TPM: `<leader> I`
8. Install ruby:
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
9. Install VSCode extensions
    ```shell
    sh install-vscode-extensions.sh
    ```
    Get extensions list:
    ```shell
    code --list-extensions
    ```
10. Install MacOs Settings
    ```shell
    source install-macos-settings.sh
    ```

## Install on a Debian/Ubuntu server (headless, SSH)

Uses the `home-forge` stow package instead of `home` (patched paths, tmux configured
to survive SSH disconnects and not leak the remote clipboard). Verified on Ubuntu 26.04.

Prerequisite: [mise](https://mise.jdx.dev) manages the runtimes and `.zshrc` activates it.
Step 4 is the only one performed on the client machine, not the server.

1. Packages. `git`, `tmux`, `fzf` and `ripgrep` are often already installed.

    ```shell
    sudo apt update
    sudo apt install -y stow zsh neovim fd-find bat lsd git-delta \
      zsh-autosuggestions zsh-syntax-highlighting
    sudo locale-gen fr_FR.UTF-8 && sudo update-locale
    ```

2. Debian ships as `fdfind` and `batcat` the two binaries `.zshrc` calls `fd` and `bat`.
   Without these links, `Ctrl-T` and `Alt-C` are dead:

    ```shell
    mkdir -p ~/.local/bin
    ln -sf "$(command -v fdfind)" ~/.local/bin/fd
    ln -sf "$(command -v batcat)" ~/.local/bin/bat
    ```

3. Oh My Zsh, Powerlevel10k and fzf-tab. Powerlevel10k has no Debian/Ubuntu package;
   the git clone is the official route on Linux. fzf-tab is not optional either —
   `.zshrc` lists it in `plugins=()`, and its absence warns on every shell start.
   `--unattended` stops the installer from running `chsh` on its own: the shell
   switch comes last, once the config is proven.

    ```shell
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.local/share/p10k
    git clone --depth=1 https://github.com/Aloxaf/fzf-tab ~/.oh-my-zsh/custom/plugins/fzf-tab
    ```

4. On the machine you connect **from**, install [MesloLGS NF](https://github.com/romkatv/powerlevel10k#manual-font-installation)
   and select it in the terminal. Glyphs are drawn by the client, so nothing installed
   on the server can fix missing ones. `.p10k.zsh` runs in `nerdfont-complete` mode —
   a Nerd Fonts v3 face renders shifted glyphs rather than none.

5. Dotfiles. Oh My Zsh has just written its own `~/.zshrc`, which would block stow:

    ```shell
    git clone https://github.com/XabAyca/dotfiles ~/.dotfiles
    cd ~/.dotfiles
    stow -n -v --no-folding home-forge          # dry run, writes nothing
    rm -f ~/.zshrc ~/.gitconfig
    stow --no-folding home-forge
    ```

    Add `-t ~` when the repository lives anywhere other than directly under `$HOME`.

6. Tmux plugins: launch `tmux`, then `Ctrl-A + I`. TPM clones itself on first launch.

7. Test before switching shells. Keep **two** SSH sessions open and, in one of them,
   run `zsh -l` — a child process you leave with `exit`, never `source ~/.zshrc`,
   which asks bash to read zsh. Check the p10k prompt and its glyphs, `node -v` and
   `which claude` (the mise test), `git diff` rendered by delta, `Ctrl-T` / `Ctrl-R` /
   `Alt-C`, `cd <Tab>`, `ll`, `nvim`, and `C-hjkl` across tmux panes and nvim splits.

8. Only once that is reliable, several sessions in a row:

    ```shell
    chsh -s "$(which zsh)"
    ```

    Open a **new** SSH connection and confirm it reaches the prompt before closing the
    others. Roll back from a live session with `chsh -s /bin/bash`.

Optional:

- `zdiff3` instead of `diff3` for `merge.conflictstyle`, and `syntax-theme = gruvbox-dark`
  under `[delta]` — check the name against `delta --list-syntax-themes` first.
- Version managers `rbenv` / `pyenv` / `nodenv`: only if you need Ruby or Python on the
  server; the lazy-load stubs in `.zshrc` are no-ops otherwise.
