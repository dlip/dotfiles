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

Follow the [NixOS](./nix/nixos-install.md) install or [install Nix](https://nixos.org/download) into your current distribution

Run [dotinstall](./bin/dotinstall) to clone into your home directory:

```sh
curl -sL https://raw.githubusercontent.com/dlip/dotfiles/refs/heads/main/bin/dotinstall | bash
```

This clones the repo's `.git` into `~`, backs up any conflicting files to `~/.dotbackup`, then checks out.

## Home Manager

`nix/home/` contains the standalone `docker`, `coder`, and `cloudide` profiles; `docker-arm` reuses `docker.nix`. App configuration files are tracked directly in this repository rather than installed through Home Manager.

If using standalone nix, add a config to [nix/modules/homemanager.nix](nix/modules/homemanager.nix) then and to ~/.zshrc.local, replacing `CONFIG` with the name

```sh
export NIXCONFIG=CONFIG
```

Open a new shell and run this to switch:

```sh
nixconfig
```

## Longshot on `x`

[Longshot](https://git.magicbean.dev/MagicBeanDev/Longshot) is packaged natively as `.#longshot` and included in `x`'s system packages, alongside Hookshot. Its source and controller-prompt dependencies are pinned in `flake.lock`; it does not download an external compiler or use an AppImage environment.

The local installation keeps its builder at `~/.local/share/longshot/tools` (a Nix GC root) and its built game at `~/Games/Longshot`. Start it from the **Longshot** applications entry or run `~/Games/Longshot/longshot`. After system activation, `longshot` also starts that folder; `longshot --cli` runs the builder.

The initial build uses Hookshot's extracted `romfs` and `.hookshot_exefs`, with RomFS hard-linked rather than duplicated. Settings and caches are separate. Saves are in `~/.local/share/longshot/save`; Hookshot's saves are not imported or modified. See the upstream [save-transfer guide](https://git.magicbean.dev/MagicBeanDev/Longshot/src/branch/main/docs/saves.md) to carry over an adventure after closing both games.

To update the source and rebuild the local game, run from this repository:

```sh
nix flake update longshot
nix build --impure .#longshot --out-link "$HOME/.local/share/longshot/tools"
"$HOME/.local/share/longshot/tools/bin/longshot" --cli --update "$HOME/Games/Longshot" --jobs 4
```

The build log is `~/.cache/longshot-builder/build.log`; runtime caches and logs are in `~/Games/Longshot/cache` and `~/Games/Longshot/logs`.

## Gamescope focus on `x`

The Gamescope Alt+Tab helper preserves app identities already discovered by Gamescope. Only otherwise-unfocusable normal app windows receive a generic non-Steam app tag; replacing a Steam-launched game's identity can prevent Steam Input from restoring its controller layout.

Steam uses its UI controller layout while its window is focused. Returning to a Steam-launched game restores that game's layout.

**Super+B** opens Blueman in the Gamescope session (either Super key works). It uses a separate D-Bus session so it does not activate a manager on another desktop; pressing it again focuses the existing window. Closing Blueman restores the previous app. The `x` host enables Blueman's package and Bluetooth service integration.

Steam's **Switch to Desktop** power-menu action opens regular Steam inside the same Gamescope session. The session uses its own Steam FHS environment with `-steamos3` and a `steamos-session-select plasma` hook, instead of Steam's display-manager user-switch fallback. The hook returns promptly and dispatches the UI change in a detached worker, then focuses Steam's new window without changing its app identity. It does not stop Steam, terminate Gamescope, or change the login session. Use Steam's **View → Big Picture Mode** to return.

Apply changes with `sudo nixos-rebuild switch --flake /home/dane#x`. Shortcut changes take effect without restarting Steam. The desktop-menu integration needs one Gamescope-session restart after the initial rebuild to load its custom Steam environment and launch flag; subsequent menu switches do not log out. Worker errors are recorded in `$XDG_RUNTIME_DIR/steam-desktop.log`.

## Language tooling

The `lsp` list in [`nix/pkgs/groups.nix`](nix/pkgs/groups.nix) is included in the `default`, `extra`, and `gui` package groups. It includes TypeScript/JavaScript, Bash, YAML, HTML, CSS, and JSON language servers, plus the `vscode-js-debug` debugger.

`vscode-js-debug` provides `js-debug`; omp needs an adapter-path override to use it. Python debugging also requires `debugpy` in the Python environment used by omp's adapter.

## Adding or removing tracked files

The repo uses an ignore-everything allowlist in `.gitignore`:

```
/*              # ignore everything
!/.zshrc        # explicitly track individual files
!/bin           # or entire directories
```

- **Adding a file**: add a `!/<path>` entry to `.gitignore`, then `git add` the file.
- **Removing a file**: delete the `!/<path>` entry from `.gitignore` and `git rm` the file.
