# Dotfiles

- Tmux ([TPM](https://github.com/tmux-plugins/tpm), [Starship](https://starship.rs/), `t` session manager)
- NeoVim ([LazyVim](https://www.lazyvim.org/))
- ZSH ([Antidote](https://github.com/mattmc3/antidote))
- Homebrew (Using Brewfile with lock)

## Setup

- Fork the project and git clone it to your home directory
- Do a search for 'Dane Lipscombe', replace with your name then commit the changes
- Run from home directory

```
mv dotfiles/.git ~
rm -rf dotfiles
git diff-index --diff-filter=dr --name-only HEAD # CHECK THE FILES WITH MODIFICATIONS AND MAKE A COPY AS NEEDED AS THESE ARE ABOUT TO BE REPLACED!!
git reset --hard
git submodule update --init
```

- Install and run Kitty "macOS dmg" <https://github.com/kovidgoyal/kitty/releases/latest>
- Open System Settings > Privacy & Security > Full Disk Access, enable kitty and restart it
- Run `retry brew-install`

Note: the .gitignore ignores all files so to add a new file run `git add -f filename` to force add it

## Homebrew management

- `brew-install` Install programs in Brewfile
- `brew-save` Run after `brew install foo` to add to Brewfile
- `brew-upgrade` Upgrade installed programs
- `brew-cleanup` Run after removing programs from the Brewfile to uninstall them
