# :floppy_disk: dotfiles

## Install

1. Clone this repository:
    ```shell
    cd
    git clone https://github.com/XabAyca/dotfiles.git .dotfiles
    cd .dotfiles
    ```
2. Install Homebrew from https://brew.sh/
3. Install applications: `brew bundle`
4. Set dotfiles: `stow --no-folding home`
5. Install z: `mkdir -p ~/.local/share && touch ~/.local/share/z`
6. Install ruby:
    ```shell
    rbenv install -l
    rbenv install <version>
    rbenv global <version>
    ```
7. Install global gems: `bundle install`

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
