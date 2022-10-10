# :floppy_disk: dotfiles

## Install

1. Clone this repository:
    ```shell
    cd
    git clone https://github.com/guillaumeboudon/dotfiles.git .dotfiles
    cd .dotfiles
    ```
2. Install own dependencies:
    ```shell
    mkdir -p ~/code/guillaumeboudon
    git clone https://github.com/guillaumeboudon/base16-scripts.git ~/code/guillaumeboudon/base16-scripts
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
- Reset to default
  - defaults delete NSGlobalDomain KeyRepeat
  - defaults delete NSGlobalDomain InitialKeyRepeat
- initial values
  - KeyRepeat : 2 (30ms)
  - InitialKeyRepeat : 15 (225ms)

## Todo

Implement ctags for rails apps:

```shell
ctags --tag-relative -Rf.tags --exclude=.git --exclude=tmp --exclude=public --exclude=log --exclude=elm-stuff --exclude=node_modules --languages=ruby .
```
