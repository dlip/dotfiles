parts: {
  flake.modules.nixos.hosts_x =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      params = {
        hostname = "x";
      };
    in
    {
      imports = [
        # Include the results of the hardware scan.
        (import ../../systems/common params)

        parts.config.flake.modules.nixos.niri
        # ../common/desktop/sway.nix
        # ../common/desktop/hyprland.nix
        # ../common/desktop/niri.nix
        # ../common/desktop/xfce.nix
        # ../common/desktop/leftwm.nix
        # ../common/desktop/kde.nix
        # ../common/desktop/awesome.nix
        # ../common/desktop/i3.nix
      ];

      boot.initrd.availableKernelModules = [
        "xhci_pci"
        "nvme"
        "thunderbolt"
        "usb_storage"
        "sd_mod"
        "rtsx_pci_sdmmc"
      ];
      boot.initrd.kernelModules = [ ];
      boot.kernelModules = [
        "kvm-intel"
        "iwlwifi"
      ];
      boot.extraModulePackages = [ ];

      fileSystems."/" = {
        device = "/dev/disk/by-uuid/bd5f124c-0d5a-4c3b-b4ec-755503b74099";
        fsType = "ext4";
      };

      boot.initrd.luks.devices."luks-e6807611-6e16-4a57-aa19-80e7efd2ec72".device =
        "/dev/disk/by-uuid/e6807611-6e16-4a57-aa19-80e7efd2ec72";

      fileSystems."/boot/efi" = {
        device = "/dev/disk/by-uuid/2FAC-32E0";
        fsType = "vfat";
      };

      fileSystems."/media/media" = {
        device = "//10.10.0.123/media";
        fsType = "cifs";
        options = [
          "uid=1000,gid=100,x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s,credentials=/etc/nixos/smb-secrets"
        ];
      };
      fileSystems."/media/media2" = {
        device = "//10.10.0.123/media2";
        fsType = "cifs";
        options = [
          "uid=1000,gid=100,x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s,credentials=/etc/nixos/smb-secrets"
        ];
      };
      fileSystems."/media/personal" = {
        device = "//10.10.0.123/personal";
        fsType = "cifs";
        options = [
          "uid=1000,gid=100,x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s,credentials=/etc/nixos/smb-secrets"
        ];
      };
      fileSystems."/media/games" = {
        device = "//10.10.0.123/games";
        fsType = "cifs";
        options = [
          "uid=1000,gid=100,x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s,credentials=/etc/nixos/smb-secrets"
        ];
      };

      swapDevices = [
        {
          device = "/.swapfile";
          size = 2048;
        }
      ];

      # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
      # (the default) this is the recommended approach. When using systemd-networkd it's
      # still possible to use this option, but it's recommended to use it in conjunction
      # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
      networking.useDHCP = lib.mkDefault true;
      # networking.interfaces.wlp0s20f3.useDHCP = lib.mkDefault true;

      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
      hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
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
        ]; # Enable ‘sudo’ for the user.
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

      environment.systemPackages = with pkgs; groups.gui ++ groups.gaming;

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

      sops.secrets.nordvpnLogin = {
        sopsFile = ../common/secrets/secrets.yaml;
      };

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

      # TODO: get this working
      networking.wireguard.interfaces = {
        wg0 = {
          ips = [ "10.100.0.5/24" ];
          privateKeyFile = config.sops.secrets.wireguard-key.path;
          listenPort = 51820;

          peers = [
            (import ../common/wireguard/dex-peer.nix)
          ];
        };
      };

      system.stateVersion = "23.05";
    };
}
