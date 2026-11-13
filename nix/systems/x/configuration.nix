# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ self, inputs, ... }:
{
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    inputs.eden.nixosModules.default
    self.modules.nixos.common
    self.modules.nixos.sops
    self.modules.nixos.niri
    self.modules.nixos.whisrs
  ];

  programs.eden.enable = true;
  services.openssh.enable = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.supportedFilesystems = [ "ntfs" ];
  users.users.dane = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "docker"
      "networkmanager"
      "dialout"
      "adbusers"
      "cdrom"
      "nordvpn"
    ]; # Enable ‘sudo’ for the user.
  };

  services.whisrs = {
    enable = true;
    user = "dane";
    cuda = true;
    # GPU decoding makes a larger model than base.en affordable.
    model = "small.en";
    modelHash = "sha256-xhONbVjsyDIgl+D5h8MvG+i7ChhTKj+I9zTRu/nEHl0=";
  };

  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    user = "dane";
    group = "users";
  };

  programs.virt-manager.enable = true;
  users.groups.libvirtd.members = [ "dane" ];
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;
  environment.systemPackages =
    with pkgs;
    groups.gui
    ++ groups.gaming
    ++ [
      godot
      hookshot
      hermes-desktop
      zed-editor
      codex
      manatan
      pokedinner
      nup
      nx2android
      lichii
      omp
    ];

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      intel-vaapi-driver # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      libva-vdpau-driver
      libvdpau-va-gl
    ];
  };
  hardware.enableAllFirmware = true;
  hardware.opentabletdriver.enable = true;

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
    # of just the bare essentials.
    powerManagement.enable = true;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of
    # supported GPUs is at:
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
    # Only available from driver 515.43.04+
    # Currently alpha-quality/buggy, so false is currently the recommended setting.
    open = false;

    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    # nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.beta;
  };
  hardware.nvidia.prime = {
    # sync.enable = true;
    offload = {
      enable = true;
      enableOffloadCmd = true;
    };
    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:1:0:0";
  };
  services.flatpak.enable = true;

  sops.secrets.nordvpnLogin = { };

  # systemd.services.keyd = {
  #   description = "keyd daemon";
  #   wantedBy = ["sysinit.target"];
  #   requires = ["local-fs.target"];
  #   after = ["local-fs.target"];
  #   serviceConfig = {
  #     Type = "simple";
  #     ExecStart = ''${pkgs.keyd}/bin/keyd'';
  #   };
  # };

  services.kanata = {
    enable = true;
    keyboards = {
      laptop = {
        devices = [ "/dev/input/by-path/platform-i8042-serio-0-event-kbd" ];
        config = builtins.readFile ../../keymaps/kanata/qwerty.kbd;
      };
    };
  };

  services.triggerhappy =
    let
      gamescopeShortcut = pkgs.writeShellScript "gamescope-shortcut" ''
        for steam_pid in $(${pkgs.procps}/bin/pgrep --euid "$UID" --exact steam); do
          unset DISPLAY WAYLAND_DISPLAY XAUTHORITY DBUS_SESSION_BUS_ADDRESS XDG_RUNTIME_DIR XDG_SESSION_ID
          while IFS= read -r -d "" variable; do
            case "$variable" in
              DISPLAY=*|XAUTHORITY=*|DBUS_SESSION_BUS_ADDRESS=*|XDG_RUNTIME_DIR=*|XDG_SESSION_ID=*)
                declare -x "$variable"
                ;;
            esac
          done < "/proc/$steam_pid/environ"
          [[ -n "''${XDG_SESSION_ID:-}" ]] || continue
          [[ $(${pkgs.systemd}/bin/loginctl show-session "$XDG_SESSION_ID" --property=Desktop --value) == steam ]] || continue
          [[ $(${pkgs.systemd}/bin/loginctl show-session "$XDG_SESSION_ID" --property=Active --value) == yes ]] || continue
          case "$1" in
            volume-up)
              exec ${pkgs.wireplumber}/bin/wpctl set-volume --limit 1 @DEFAULT_AUDIO_SINK@ 5%+
              ;;
            volume-down)
              exec ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
              ;;
            mute)
              exec ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
              ;;
            mic-mute)
              exec ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
              ;;
            quit)
              exec ${pkgs.systemd}/bin/loginctl terminate-session "$XDG_SESSION_ID"
              ;;
            kill-app)
              window=$(${pkgs.xdotool}/bin/xdotool getwindowfocus) || exit 1
              [[ "$window" =~ ^[0-9]+$ && "$window" -gt 1 ]] || exit 0
              exec ${pkgs.xdotool}/bin/xdotool windowkill "$window"
              ;;
            cycle)
              read -r _ _ focusable < <(${pkgs.xprop}/bin/xprop -root -notype GAMESCOPE_FOCUSABLE_WINDOWS)
              IFS=', ' read -r -a entries <<< "$focusable"
              windows=()
              # Gamescope publishes [window, app ID, PID] triplets in focus-priority order.
              for ((i = 0; i < ''${#entries[@]}; i += 3)); do
                windows+=("''${entries[i]}")
              done
              # Apps launched outside Steam need a game tag before Gamescope can focus them.
              for candidate in $(${pkgs.xdotool}/bin/xdotool search --onlyvisible --class .); do
                properties=$(${pkgs.xprop}/bin/xprop -id "$candidate" -notype \
                  STEAM_GAME STEAM_OVERLAY GAMESCOPE_EXTERNAL_OVERLAY \
                  WM_TRANSIENT_FOR _NET_WM_WINDOW_TYPE _NET_WM_STATE) || continue
                case "$properties" in
                  *"STEAM_GAME = "[1-9]*|*"STEAM_OVERLAY = "[1-9]*|*"GAMESCOPE_EXTERNAL_OVERLAY = "[1-9]*|*"WM_TRANSIENT_FOR = "*|*"_NET_WM_STATE_SKIP_TASKBAR"*)
                    continue
                    ;;
                esac
                if [[ "$properties" == *"_NET_WM_WINDOW_TYPE = "* && "$properties" != *"_NET_WM_WINDOW_TYPE_NORMAL"* ]]; then
                  continue
                fi
                ${pkgs.xprop}/bin/xprop -id "$candidate" -f STEAM_GAME 32c -set STEAM_GAME 2147483648 || continue
                windows+=("$candidate")
              done
              (( ''${#windows[@]} > 1 )) || exit 0
              # Stable window order lets repeated Alt+Tab reach every app, not just the last two.
              mapfile -t windows < <(printf '%s\n' "''${windows[@]}" | ${pkgs.coreutils}/bin/sort -nu)
              read -r _ _ focused < <(${pkgs.xprop}/bin/xprop -root -notype GAMESCOPE_FOCUSED_WINDOW)
              next="''${windows[0]}"
              for ((i = 0; i < ''${#windows[@]}; i++)); do
                if [[ "''${windows[i]}" == "$focused" ]]; then
                  next="''${windows[(i + 1) % ''${#windows[@]}]}"
                  break
                fi
              done
              exec ${pkgs.xprop}/bin/xprop -root -f GAMESCOPECTRL_BASELAYER_WINDOW 32c -set GAMESCOPECTRL_BASELAYER_WINDOW "$next"
              ;;
            terminal)
              [[ -n "''${DISPLAY:-}" ]] || continue
              export HOME=/home/dane USER=dane LOGNAME=dane
              ${pkgs.kitty}/bin/kitty --override linux_display_server=x11 --directory "$HOME" &
              kitty_pid=$!
              if ! window=$(${pkgs.coreutils}/bin/timeout 10s ${pkgs.xdotool}/bin/xdotool search --sync --onlyvisible --limit 1 --pid "$kitty_pid"); then
                echo "Kitty did not create an X11 window" >&2
                kill "$kitty_pid" 2>/dev/null || true
                wait "$kitty_pid" || true
                exit 1
              fi
              read -r _ _ previous_focus < <(${pkgs.xprop}/bin/xprop -root -notype GAMESCOPECTRL_BASELAYER_WINDOW)
              # Steam mode ignores untagged windows; identify kitty as a non-Steam app.
              ${pkgs.xprop}/bin/xprop -id "$window" -f STEAM_GAME 32c -set STEAM_GAME 2147483648
              ${pkgs.xprop}/bin/xprop -root -f GAMESCOPECTRL_BASELAYER_WINDOW 32c -set GAMESCOPECTRL_BASELAYER_WINDOW "$window"
              wait "$kitty_pid"
              status=$?
              if read -r _ _ current_focus < <(${pkgs.xprop}/bin/xprop -root -notype GAMESCOPECTRL_BASELAYER_WINDOW); then
                if [[ "$current_focus" == "$window" ]]; then
                  ${pkgs.xprop}/bin/xprop -root -f GAMESCOPECTRL_BASELAYER_WINDOW 32c -set GAMESCOPECTRL_BASELAYER_WINDOW "$previous_focus"
                fi
              fi
              exit "$status"
              ;;
          esac
        done
      '';
    in
    {
      enable = true;
      user = "dane";
      bindings =
        builtins.concatMap
          (
            super:
            [
              {
                keys = [
                  "Q"
                  super
                ];
                cmd = "${gamescopeShortcut} kill-app";
              }
              {
                keys = [
                  "T"
                  super
                ];
                cmd = "${gamescopeShortcut} terminal";
              }
            ]
            ++
              builtins.map
                (shift: {
                  keys = [
                    "Q"
                    super
                    shift
                  ];
                  cmd = "${gamescopeShortcut} quit";
                })
                [
                  "LEFTSHIFT"
                  "RIGHTSHIFT"
                ]
          )
          [
            "LEFTMETA"
            "RIGHTMETA"
          ]
        ++
          builtins.map
            (alt: {
              keys = [
                "TAB"
                alt
              ];
              cmd = "${gamescopeShortcut} cycle";
            })
            [
              "LEFTALT"
              "RIGHTALT"
            ]
        ++
          builtins.concatMap
            (event: [
              {
                keys = [ "VOLUMEUP" ];
                inherit event;
                cmd = "${gamescopeShortcut} volume-up";
              }
              {
                keys = [ "VOLUMEDOWN" ];
                inherit event;
                cmd = "${gamescopeShortcut} volume-down";
              }
            ])
            [
              "press"
              "hold"
            ]
        ++ [
          {
            keys = [ "MUTE" ];
            cmd = "${gamescopeShortcut} mute";
          }
          {
            keys = [ "MICMUTE" ];
            cmd = "${gamescopeShortcut} mic-mute";
          }
        ];
    };

  networking.firewall = {
    allowedTCPPorts = [
      3000
      4000
      9901
    ];
    allowedUDPPorts = [
      51820
      32412
    ]; # Clients and peers can use the same port, see listenport
  };

  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };
  hardware.steam-hardware.enable = true;

  programs.obs-studio = {
    enable = true;
    plugins = [ pkgs.obs-studio-plugins.droidcam-obs ];
    enableVirtualCamera = true;
    package = pkgs.obs-studio.override { cudaSupport = true; };
  };

  sops.secrets.wireguard-key = { };
  networking.wireguard.interfaces = {
    wg0 = {
      ips = [ "10.100.0.5/24" ];
      privateKeyFile = config.sops.secrets.wireguard-key.path;
      listenPort = 51820;

      peers = [
        self.modules.nixos.wireguard-dex-peer
      ];
    };
  };

  services.nordvpn.enable = true;

  system.stateVersion = "23.05";
}
