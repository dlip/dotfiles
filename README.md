# Dotfiles

Personal dotfiles and Nix system configurations, managed as a bare-style repo checked out directly into `~`.

## What's included

- **Nix flake** — NixOS system configs for multiple hosts (`dex`, `x`, `ptv`, `metabox`), Home Manager profiles, nix-on-droid, and custom packages. Uses the [dendritic pattern](https://github.com/vic/import-tree) with [flake-parts](https://github.com/hercules-ci/flake-parts) for auto-discovered modules.
- **Shell** — Zsh config, tmux, starship prompt, aliases and scripts in `bin/`.
- **Editors** — Neovim, VS Code, Zed.
- **Desktop** — Niri, Hyprland, waybar, rofi, swaync, yazi, Ghostty, kitty.
- **Media** — mpv with subs2srs, Plex, Jellyfin, Kodi.
- **macOS** — Aerospace, custom Engrammer keyboard layout, Homebrew Brewfile.

## Setup

Run [dotinstall](./bin/dotinstall) to clone into your home directory:

```sh
curl -sL https://raw.githubusercontent.com/dlip/dotfiles/refs/heads/main/bin/dotinstall | bash
```

This clones the repo's `.git` into `~`, backs up any conflicting files to `~/.dotbackup`, then checks out.

## Adding or removing tracked files

The repo uses an ignore-everything allowlist in `.gitignore`:

```
/*              # ignore everything
!/.zshrc        # explicitly track individual files
!/bin           # or entire directories
```

- **Adding a file**: add a `!/<path>` entry to `.gitignore`, then `git add` the file.
- **Removing a file**: delete the `!/<path>` entry from `.gitignore` and `git rm` the file.
