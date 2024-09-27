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
