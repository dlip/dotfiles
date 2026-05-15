# Agent Guidelines

## Overview

This is a **NixOS/home-manager dotfiles repository**.

### Key Structure

- **`flake.nix`** — Nix flake with all inputs and module imports
- **`nix/modules/`** — Configuration modules (flake-parts based)
  - `nixos/` — NixOS system config (common, niri, xfce, sops, etc.)
  - `homemanager.nix` — User-level config (shell, programs, etc.)
- **`dotfiles/`** — Home directory dotfile backups
- **`bin/dotinstall`** — Bootstrap script for new machines

### Key Technologies

- Nix/NixOS with flakes and home-manager
- Zsh + antigen plugins
- Xfce + Niri (Wayland compositor)
- SOPS-Nix for secrets
- Nix-on-Droid for mobile

## Editing Rules

- **Only modify lines related to your task** — Do not make unrelated changes to existing code or config
- When adding new files, always update `.gitignore` with the `!/` prefix

---

## When Adding New Files

Any new file tracked by git must also be added to `.gitignore` with `!/` prefix to unignore it. For example:

```
!/AGENTS.md
```

This pattern prevents accidentally committing generated or user-specific files.

---

## Working in This Repo

### Do Not Modify

- **`.gitignore`d files** — These exist in `$HOME` but are unrelated to this repo (cache, state, credentials, etc.)
- Files in the root directory that are not listed above

### Focus Areas

Only modify files that are:
1. Tracked by git (`git ls-files`)
2. Related to NixOS/home-manager configuration
3. Shell scripts in `bin/`
4. Documentation files (`.md`)

### Before Making Changes

Run `git status` to confirm you're editing tracked, relevant files. If a file you're working with appears to be gitignored or outside the scope above, ask the user to confirm.
