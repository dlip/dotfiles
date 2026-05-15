# AGENTS.md

## Repository Overview

This is a **dotfiles repository** checked out directly into the home directory (`~`). It tracks personal configuration files for various tools and systems including Nix, Neovim, Hyprland, Niri, tmux, Zsh, Ghostty, kitty, mpv, yazi, and many others.

## Important: .gitignore Convention

Because the repo lives in `~`, the `.gitignore` uses an **ignore-everything-then-allowlist** pattern:

```
/*                          # ignore everything by default
!/.config/ghostty/config    # explicitly unignore tracked files
!/bin
...
```

### When you add a new file

You **must** add a corresponding `!/<path>` entry to `.gitignore` so git will track it. Place the entry in the appropriate sorted section (top-level dotfiles, `Library/`, `.config/`, etc.) to keep the file organized.

### When you delete a tracked file

You **must** remove its `!/<path>` entry from `.gitignore` as well.

### When you add a new directory

If the entire directory should be tracked, add a single `!/<dirname>` entry (e.g. `!/bin`). Git will recursively include it. If only specific files inside the directory should be tracked, add entries for each file individually.

## Repository Structure

- **Top-level dotfiles** — `.zshrc`, `.profile`, `.gitignore`, `.gitmodules`, `.zsh_plugins.txt`, `Brewfile`, etc.
- **`bin/`** — Personal shell scripts and utilities.
- **`.config/`** — XDG config files for Linux/macOS tools (Neovim, Ghostty, kitty, Niri, Hyprland, tmux, waybar, rofi, starship, yazi, zed, etc.).
- **`nix/`** — Nix flake configuration: NixOS systems, Home Manager modules, custom packages, and secrets.
- **`docker/`** — Docker helper scripts and Dockerfile.
- **`Library/`** — macOS-specific configs (keyboard layouts, app settings).
- **`flake.nix` / `flake.lock`** — Top-level Nix flake for the entire system configuration.

## General Guidelines

- This repo is configuration-only. Don't add build artifacts, caches, or generated files.
- Many configs reference [Catppuccin Macchiato](https://github.com/catppuccin/catppuccin) as the color scheme.
- Shell scripts in `bin/` should be executable and have shebangs.
- Nix configurations are managed as a flake with multiple system targets — see `nix/systems/` for per-host configs and `nix/home/` for Home Manager modules.
