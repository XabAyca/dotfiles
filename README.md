# :floppy_disk: dotfiles

## Install

1. Clone this repository:
    ```shell
    cd
    git clone https://github.com/XabAyca/dotfiles.git .dotfiles
    cd .dotfiles
    ```
2. Install own dependencies:
    ```shell
    mkdir -p ~/code/XabAyca
    git clone https://github.com/XabAyca/base16-scripts.git ~/code/XabAyca/base16-scripts
    ```
3. Install Homebrew from https://brew.sh/
4. Install applications: `brew bundle`
5. Set dotfiles: `stow --no-folding home`
6. Install z: `mkdir -p ~/.local/share && touch ~/.local/share/z`
7. Install ruby:
    ```shell
    rbenv install -l
    rbenv install <version>
    rbenv global <version>
    ```
8. Install global gems: `bundle install`

## Change key repeat on Mac OSX

- My config
  - defaults write -g KeyRepeat -int 1
  - defaults write -g InitialKeyRepeat -int 10
  - defaults write com.apple.dock "autohide-time-modifier" -float "0.2" && killall Dock
- Reset to default
  - defaults delete NSGlobalDomain KeyRepeat
  - defaults delete NSGlobalDomain InitialKeyRepeat
- initial values
  - KeyRepeat : 2 (30ms)
  - InitialKeyRepeat : 15 (225ms)
