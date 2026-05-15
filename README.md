# Dotfiles

My dotfiles and nix config

## Setup

```
git clone https://github.com/dlip/dotfiles.git
mv dotfiles/.git ~
rm -rf dotfiles
git diff-index --diff-filter=dr --name-only HEAD # CHECK THE FILES WITH MODIFICATIONS AND MAKE A COPY AS NEEDED AS THESE ARE ABOUT TO BE REPLACED!!
git reset --hard
git submodule update --init
```

Note: the .gitignore ignores all files so to add a new file run `git add -f filename` to force add it

