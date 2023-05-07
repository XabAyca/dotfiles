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
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k
    ```
4. Install applications: `brew bundle`
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
## Change key repeat on Mac OSX

- My config
  - defaults write -g KeyRepeat -int 1
  - defaults write -g InitialKeyRepeat -int 10
  - defaults write com.apple.dock autohide-delay -float 0
  - defaults write com.apple.dock autohide-time-modifier -float 0.2
  - killall Dock
  - defaults write com.apple.finder AppleShowAllFiles -bool YES
  - killall Finder
