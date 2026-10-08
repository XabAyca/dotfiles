# :floppy_disk: dotfiles

Two [stow](https://www.gnu.org/software/stow/) packages, one per machine:

| Package      | Machine                         | Tools come from        |
|--------------|---------------------------------|------------------------|
| `home`       | macOS laptop                    | Homebrew (`Brewfile`)  |
| `home-forge` | headless Ubuntu server, via SSH | apt + mise             |

Some pieces install themselves on first launch, nothing to do for them:

- Powerlevel10k (server) and fzf-tab: cloned into `~/.local/share` by `.zshrc`.
- tmux plugins: `.tmux.conf` clones TPM and installs the plugins.
- nvim plugins: lazy.nvim bootstraps itself.

## macOS

1. Install Homebrew from https://brew.sh/
2. Clone this repository:

    ```shell
    git clone https://github.com/XabAyca/dotfiles ~/.dotfiles
    cd ~/.dotfiles
    ```

3. Install the CLI tools, apps and fonts: `brew bundle`
4. Link the dotfiles. A `~/.zshrc` or `~/.gitconfig` already in place would block stow:

    ```shell
    stow -n -v --no-folding home          # dry run, writes nothing
    stow --no-folding home
    ```

5. Install the runtimes:

    ```shell
    rbenv install <version> && rbenv global <version>
    pyenv install <version> && pyenv global <version>
    nodenv install <version> && nodenv global <version>
    rustup default stable
    ```

6. iTerm2: Settings > Settings > Import, and pick `iTerm2_State.itermexport`.
7. VSCode extensions: `sh install-vscode-extensions.sh`
   (to refresh the list: `code --list-extensions`).
8. macOS settings: `source install-macos-settings.sh`

## Ubuntu server (headless, SSH)

`home-forge` patches the paths for Linux and configures tmux to survive SSH
disconnects without leaking the remote clipboard. Verified on Ubuntu 26.04.

Prerequisite: [mise](https://mise.jdx.dev), which manages the runtimes (node, rust,
claude, …) listed in `~/.config/mise/config.toml`.

1. Packages. `git`, `tmux`, `fzf` and `ripgrep` are often already installed.

    ```shell
    sudo apt update
    sudo apt install -y stow zsh neovim fd-find bat lsd git-delta \
      zsh-autosuggestions zsh-syntax-highlighting
    sudo locale-gen fr_FR.UTF-8 && sudo update-locale
    ```

2. Font, on the machine you connect **from**: install
   [MesloLGS NF](https://github.com/romkatv/powerlevel10k#manual-font-installation)
   and select it in the terminal. Glyphs are drawn by the client, so nothing installed
   on the server can fix missing ones. `.p10k.zsh` runs in `nerdfont-complete` mode —
   a Nerd Fonts v3 face renders shifted glyphs rather than none.

3. Link the dotfiles. A `~/.zshrc` or `~/.gitconfig` already in place would block stow:

    ```shell
    git clone https://github.com/XabAyca/dotfiles ~/.dotfiles
    cd ~/.dotfiles
    stow -n -v --no-folding home-forge          # dry run, writes nothing
    rm -f ~/.zshrc ~/.gitconfig
    stow --no-folding home-forge
    ```

    Add `-t ~` when the repository lives anywhere other than directly under `$HOME`.

    The package also ships `fd` and `bat` (Debian names them `fdfind` and `batcat`)
    and `emojify`, which `.gitconfig` pipes git's output through to render gitmoji.

    `~/.claude/CLAUDE.md` ships with it too: the baseline rules every agent reads,
    in every project. Claude Code picks it up on its own; other agents look for
    `AGENTS.md`, so point one at it:

    ```shell
    ln -sfn .claude/CLAUDE.md ~/AGENTS.md
    ```

4. Install the runtimes: `mise install`

5. Test before switching shells. Keep **two** SSH sessions open and, in one of them,
   run `zsh -l` — a child process you leave with `exit`, never `source ~/.zshrc`,
   which asks bash to read zsh. Check the p10k prompt and its glyphs, `node -v`,
   `cargo -V` and `which claude` (the mise test), `git diff` rendered by delta,
   `git log` with its gitmoji, `Ctrl-T` / `Ctrl-R` / `Alt-C`, `cd <Tab>`, `ll`, `nvim`,
   and `C-hjkl` across tmux panes and nvim splits.

6. Only once that is reliable, several sessions in a row:

    ```shell
    chsh -s "$(which zsh)"
    ```

    Open a **new** SSH connection and confirm it reaches the prompt before closing the
    others. Roll back from a live session with `chsh -s /bin/bash`.

### Tests

The scripts of `home-forge` carry their own — no framework, no network:

```shell
find home-forge -name '*.test.sh' | while read -r t; do echo "== $t"; bash "$t" || break; done
```

### Optional

- `zdiff3` instead of `diff3` for `merge.conflictstyle`, and `syntax-theme = gruvbox-dark`
  under `[delta]` — check the name against `delta --list-syntax-themes` first.
