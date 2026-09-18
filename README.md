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

Uses the `home-forge` stow package instead of `home` (patched paths, tmux configured to survive SSH disconnects and not leak the remote clipboard).

```shell
sudo apt install -y stow zsh git tmux neovim fzf ripgrep fd-find bat \
  zsh-autosuggestions zsh-syntax-highlighting zsh-theme-powerlevel10k
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
chsh -s "$(which zsh)"
git clone https://github.com/XabAyca/dotfiles ~/.dotfiles
cd ~/.dotfiles && stow --no-folding home-forge
```

Optional:

- `lsd` (for the `ll`/`ll2` aliases): `cargo install lsd` or grab the `.deb` from the [lsd releases](https://github.com/lsd-rs/lsd/releases).
- `fzf-tab`: `git clone https://github.com/Aloxaf/fzf-tab ~/.oh-my-zsh/custom/plugins/fzf-tab`.
- `diff-so-fancy` (used by `.gitconfig` pager): `sudo apt install diff-so-fancy` (or install from source).
- Version managers `rbenv` / `pyenv` / `nodenv`: only if you actually need Ruby/Python/Node on the server; the lazy-load stubs in `.zshrc` are no-ops otherwise.
- Tmux plugins: launch `tmux`, then `Ctrl-A + I` to install via TPM.
