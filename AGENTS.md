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

## Nix Dendritic Pattern

The Nix configuration follows the **dendritic pattern** using [`import-tree`](https://github.com/vic/import-tree). The flake output is defined as:

```nix
outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./nix/modules);
```

This means **every `.nix` file under `nix/modules/` is automatically imported** — there is no central file that manually lists modules. To add new Nix functionality, simply create a new `.nix` file in the appropriate place under `nix/modules/` and it will be picked up automatically.

### Key directories

- **`nix/modules/`** — Auto-imported flake-parts modules. Entry points for NixOS (`nixos.nix`), Home Manager (`homemanager.nix`), nix-on-droid (`nixondroid.nix`), and overlays/packages (`pkgs.nix`).
- **`nix/modules/nixos/`** — Shared NixOS modules exposed as `self.modules.nixos.<name>` (e.g. `common`, `sops`, `niri`, `xfce`, `komf`, `ssmtp`, `notify-problems`). Hosts opt in to these via their `imports` list.
- **`nix/systems/`** — Per-host NixOS/darwin system configurations (e.g. `dex/`, `ptv/`, `x/`). Each host's `configuration.nix` is a curried function: `top@{ self, ... }: { config, pkgs, ... }: { ... }`. The first arg receives flake-parts attrs (including `self` for accessing `self.modules.nixos.*`), the second receives NixOS module args.
- **`nix/systems/common/`** — Shared data files only (secrets, wireguard peers). **Not** NixOS modules — all shared modules live in `nix/modules/nixos/`.
- **`nix/home/`** — Home Manager modules, composed into profiles by the hosts.
- **`nix/pkgs/`** — Custom Nix package definitions.

### How hosts are defined

All hosts use the `mkHost` helper in `nix/modules/nixos.nix`, which:
1. Passes flake-parts `top` attrs as the first curried arg to `configuration.nix`
2. Passes `hostname` and `inputs` via `specialArgs`
3. Sets up the correct `nixpkgs.pkgs` overlay

Hosts select which shared modules they need:
```nix
imports = [
  ./hardware-configuration.nix
  self.modules.nixos.common
  self.modules.nixos.sops
  self.modules.nixos.niri
];
```

### When modifying Nix config

- New modules under `nix/modules/` are auto-discovered by `import-tree` — no imports to update.
- New shared NixOS modules go in `nix/modules/nixos/` and are exposed as `self.modules.nixos.<name>`.
- Files outside `nix/modules/` (e.g. in `nix/home/`, `nix/systems/`, `nix/pkgs/`) are imported explicitly by the modules, so they must be referenced from an existing module.
- The flake uses `flake-parts` for structuring outputs.

## General Guidelines

- This repo is configuration-only. Don't add build artifacts, caches, or generated files.
- Many configs reference [Catppuccin Macchiato](https://github.com/catppuccin/catppuccin) as the color scheme.
- Shell scripts in `bin/` should be executable and have shebangs.
