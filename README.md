# Dotfiles

My dotfiles and nix config

## Setup

I use a bare git repo to make it easy to add only the files I need without a complicated .gitignore with an alias that works anywhere

```
git clone --bare https://github.com/dlip/dotfiles.git .dotfiles
alias dotfiles='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
dotfiles config --local status.showUntrackedFiles no
dotfiles submodule update --init
```

Check for existing conflicted files with `dotfiles status` then run `dotfiles reset --hard` if you are happy to remove them

