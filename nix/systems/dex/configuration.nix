# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  lib,
  ...
}:
let
  dex-services = import ./services.nix;
  downloader-services = import ../downloader/services.nix;
  domain = "dex-lips.duckdns.org";

  params = {
    hostname = "dex";
  };
in
rec {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    (import ../common params)
    # ../common/desktop/kde.nix
    # ../common/desktop/hyprland.nix
    ../common/services/notify-problems.nix
  ];

  # Open ports in the firewall.
  networking.firewall.enable = true;
  networking.firewall.allowPing = true;

  networking.firewall.allowedTCPPorts = [
    443
    445
    139
    80
    22
    8000
    6443
    1234
  ];
  networking.firewall.allowedUDPPorts = [
    137
    138
  ];

  # services.xserver.videoDrivers = ["nvidia"];

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
    # of just the bare essentials.
    powerManagement.enable = false;

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
  hardware.enableAllFirmware = true;

  systemd.services.mount-backup = {
    enable = true;
    description = "Mount backup";

    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      User = "root";
      Group = "root";
    };

    script =
      # bash
      ''
        UUID=""
        for ID in 8c4746b9-7ccb-4a94-8e72-502ea6ff4a49 05d74c77-c9f2-4101-af0b-b1c7141a4fd0; do
          if [ -e "/dev/disk/by-uuid/$ID" ]; then
            echo "found disk $ID"
            UUID=$ID
            break
          fi
        done

        if [ "$UUID" == "" ]; then
          echo "backup device not found"
          exit 1
        fi


        if ! /run/wrappers/bin/mount | grep -q -wi "/media/backup"; then
           ${pkgs.cryptsetup}/bin/cryptsetup --key-file /root/lukskey luksOpen /dev/disk/by-uuid/$UUID backup
           /run/wrappers/bin/mount /dev/mapper/backup /media/backup
        fi
      '';
  };

  users.users.tv = {
    isNormalUser = true;
    extraGroups = [ ]; # Enable ‘sudo’ for the user.
    shell = "/etc/profiles/per-user/tv/bin/zsh";
  };

  users.users.ryoko = {
    isNormalUser = true;
    home = "/media/media/home/ryoko";
    createHome = true;
    extraGroups = [ ]; # Enable ‘sudo’ for the user.
  };

  users.users.dane = {
    isNormalUser = true;
    home = "/home/dane";
    createHome = true;
    extraGroups = [
      "wheel"
      "docker"
      "networkmanager"
      "dialout"
      "adbusers"
    ]; # Enable ‘sudo’ for the user.
    shell = "/etc/profiles/per-user/dane/bin/zsh";
  };

  environment.systemPackages = with pkgs; [
    google-chrome
  ];

  # systemd.services.xboxdrv = {
  #   wantedBy = [ "multi-user.target" ];
  #   after = [ "network.target" ];
  #   serviceConfig = {
  #     Type = "forking";
  #     User = "root";
  #     ExecStart = ''${pkgs.xboxdrv}/bin/xboxdrv --daemon --detach --pid-file /var/run/xboxdrv.pid --dbus disabled --silent --deadzone 4000 --deadzone-trigger 10% --mimic-xpad-wireless'';
  #   };
  # };

  services.audiobookshelf = {
    enable = true;
    port = 13378;
  };

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      homepage = {
        image = "ghcr.io/benphelps/homepage:latest";
        volumes = [
          "/mnt/services/homepage/config:/app/config"
          "/var/run/docker.sock:/var/run/docker.sock"
        ];
        extraOptions = [ "--network=host" ];
        environment = {
          PORT = "3001";
        };
      };
      # audiobookshelf = {
      #   image = "ghcr.io/advplyr/audiobookshelf";
      #   ports = ["13378:80"];
      #   volumes = [
      #     "/mnt/services/audiobookshelf/config:/config"
      #     "/mnt/services/audiobookshelf/metadata:/metadata"
      #     "/media/media/audiobooks:/audiobooks"
      #     "/media/media/podcasts:/podcasts"
      #   ];
      # };
      yaruki = {
        image = "dlip/yaruki";
        ports = [ "8095:8080" ];
        volumes = [
          "/mnt/services/yaruki:/app/data"
        ];
      };
      # actual = {
      #   image = "actualbudget/actual-server";
      #   ports = ["5006:5006"];
      #   volumes = [
      #     "/mnt/services/actual:/data"
      #   ];
      # };
    };
  };

  services.actual = {
    enable = true;
    settings = {
      port = 5006;
    };
  };

  # systemd.services.actual-server = {
  #   wantedBy = [ "multi-user.target" ];
  #   after = [ "network.target" ];
  #   description = "Actual Server";
  #   environment = {
  #     USER_FILES = "/var/lib/actual-server/user";
  #     SERVER_FILES = "/var/lib/actual-server/server";
  #   };
  #   script = "${pkgs.actualServer}/bin/actual-server";
  # };

  # services.k3s = {
  #   enable = true;
  #   extraFlags = "--no-deploy traefik";
  # };

  services.gitea = {
    enable = true;
    settings.server.HTTP_PORT = 3002;
  };

  hardware.bluetooth.enable = true;
  networking.nat.enable = true;
  networking.nat.internalInterfaces = [
    "wg0"
    "ve-+"
  ];
  networking.nat.externalInterface = "enp8s0";

  networking.wireguard.interfaces = {
    # "wg0" is the network interface name. You can name the interface arbitrarily.
    wg0 = {
      # Determines the IP address and subnet of the server's end of the tunnel interface.
      ips = [ "10.100.0.1/24" ];

      # The port that WireGuard listens to. Must be accessible by the client.
      listenPort = 51820;

      # This allows the wireguard server to route your traffic to the internet and hence be like a VPN
      # For this to work you have to set the dnsserver IP of your router (or dnsserver of choice) in your clients
      postSetup = ''
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.100.0.0/24 -o eth0 -j MASQUERADE
      '';

      # This undoes the above command
      postShutdown = ''
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.100.0.0/24 -o eth0 -j MASQUERADE
      '';

      # Path to the private key file.
      #
      # Note: The private key can also be included inline via the privateKey option,
      # but this makes the private key world-readable; thus, using privateKeyFile is
      # recommended.
      # +YVMX+HXcyFsfxGWdWC+WdI6nUMkyMdtxsohVDJavlQ=
      privateKeyFile = config.sops.secrets.wireguard-key.path;

      # List of allowed peers.
      peers = [
        # g
        {
          publicKey = "AyT/WKTrPwaiCFLRx68Jz/isw4Rv/4PQ+y3qlNJ32HA=";
          allowedIPs = [ "10.100.0.3/32" ];
        }
        # flip
        {
          publicKey = "MLNoLlIYeq6F8NBwg/Cu95fwO7BiJbcTRq4dj5MLAzA=";
          allowedIPs = [ "10.100.0.4/32" ];
        }
        # x
        {
          publicKey = "lszSFzhXlH1JPG655cXOVawciMryUHTzQ3quh8fQnWc=";
          allowedIPs = [ "10.100.0.5/32" ];
        }
        # ptv
        {
          publicKey = "y1+RKIv+REkE/sSD1YEvSP/QQCZKeWKW+Qe9EE94oyU=";
          allowedIPs = [ "10.100.0.6/32" ];
        }
        # rmob
        {
          publicKey = "SjRIualgEpDnqE5ohIrYD+u7aeIz3zrVVwXHohenVmA=";
          allowedIPs = [ "10.100.0.7/32" ];
        }
      ];
    };
  };

  containers.downloader = {
    ephemeral = true;
    autoStart = true;
    enableTun = true;
    config = import ../downloader/configuration.nix {
      inherit pkgs config;
    };
    privateNetwork = true;
    hostAddress = "10.1.0.1";
    localAddress = "10.1.0.2";
    bindMounts = {
      "/mnt/services" = {
        hostPath = "/mnt/services";
        isReadOnly = false;
      };
      "/media/media" = {
        hostPath = "/media/media";
        isReadOnly = false;
      };
      "/media/media2" = {
        hostPath = "/media/media2";
        isReadOnly = false;
      };
      "/d" = {
        hostPath = "/d";
        isReadOnly = false;
      };
      "/f" = {
        hostPath = "/f";
        isReadOnly = false;
      };
      "/var/lib" = {
        hostPath = "/mnt/downloader/var/lib";
        isReadOnly = false;
      };
    };
  };

  sops.secrets.traefik-env = {
    owner = "traefik";
    group = "traefik";
  };

  services.cron.systemCronJobs = [
    ''*/10 * * * * root eval "export `cat /var/run/secrets/traefik-env`" && ${pkgs.curl}/bin/curl http://www.duckdns.org/update/lips-home/$DUCKDNS_TOKEN''
  ];

  systemd.services.traefik.serviceConfig.EnvironmentFile = [ "/var/run/secrets/traefik-env" ];
  services.traefik = {
    enable = true;
    staticConfigOptions = {
      log.level = "DEBUG";
      api = {
        dashboard = true;
      };
      certificatesResolvers.letsencrypt.acme = {
        email = "danelipscombe@gmail.com";
        storage = "/var/lib/traefik/acme.json";
        dnsChallenge = {
          provider = "duckdns";
          delayBeforeCheck = 5;
          resolvers = [
            "1.1.1.1:53"
            "8.8.8.8:53"
          ];
        };
      };
      entryPoints = {
        web = {
          address = ":80";
          http.redirections.entrypoint = {
            to = "websecure";
            scheme = "https";
          };
        };
        websecure = {
          address = ":443";

          http.tls = {
            certResolver = "letsencrypt";
          };
        };
      };
    };
    dynamicConfigOptions = {
      http = {
        routers =
          {
            traefik = {
              rule = "Host(`traefik.${domain}`)";
              service = "api@internal";
              tls = {
                domains = [
                  {
                    main = "*.${domain}";
                  }
                ];
                certResolver = "letsencrypt";
              };
            };
          }
          // pkgs.lib.attrsets.mapAttrs' (
            name: port:
            pkgs.lib.attrsets.nameValuePair "${name}" {
              rule = "Host(`${name}.${domain}`)";
              service = "${name}";
              tls = {
                domains = [
                  {
                    main = "*.${domain}";
                  }
                ];
                certResolver = "letsencrypt";
              };
            }
          ) (dex-services // downloader-services);

        services =
          (pkgs.lib.attrsets.mapAttrs' (
            name: port:
            pkgs.lib.attrsets.nameValuePair "${name}" {
              loadBalancer.servers = [ { url = "http://127.0.0.1:${toString port}/"; } ];
            }
          ) dex-services)
          // (pkgs.lib.attrsets.mapAttrs' (
            name: port:
            pkgs.lib.attrsets.nameValuePair "${name}" {
              loadBalancer.servers = [
                { url = "http://${containers.downloader.localAddress}:${toString port}/"; }
              ];
            }
          ) downloader-services);
      };
    };
  };
  /*
    services.nginx = {
      enable = true;
      recommendedProxySettings = true;
      virtualHosts =
        (pkgs.lib.attrsets.mapAttrs'
          (name: port:
            pkgs.lib.attrsets.nameValuePair "${name}.${domain}" {
              locations."/" = {
                proxyPass = "http://127.0.0.1:${toString port}";
                proxyWebsockets = true;
              };
            })
          dex-services)
        // (pkgs.lib.attrsets.mapAttrs'
          (name: port:
            pkgs.lib.attrsets.nameValuePair "${name}.${domain}" {
              locations."/" = {
                proxyPass = "http://${containers.downloader.localAddress}:${toString port}";
              };
            })
          downloader-services);
    };
  */
  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    guiAddress = "0.0.0.0:8384";
    user = "dane";
    group = "users";
  };

  services.plex = {
    enable = true;
    openFirewall = true;
    dataDir = "/mnt/services/plex";
    user = "root";
    group = "root";
  };

  # sops.secrets.nextcloud-adminpass = {
  #   owner = "nextcloud";
  #   group = "nextcloud";
  # };

  # services.nextcloud = {
  #   enable = true;
  #   hostName = "nextcloud.dex-lips.duckdns.org";
  #   home = "/media/media/nextcloud";
  #   config = {
  #     dbtype = "pgsql";
  #     dbuser = "nextcloud";
  #     dbhost = "/run/postgresql"; # nextcloud will add /.s.PGSQL.5432 by itself
  #     dbname = "nextcloud";
  #     adminpassFile = config.sops.secrets.nextcloud-adminpass.path;
  #     adminuser = "root";
  #   };
  #   extraApps = {
  #     calendar = pkgs.fetchzip {
  #       sha256 = "Coug3YUX4YsArzbdSzMBYRrGYak9eDK9bHmc/5u6GXY=";
  #       url = "https://github.com/nextcloud-releases/calendar/releases/download/v4.3.3/calendar-v4.3.3.tar.gz";
  #     };
  #     notes = pkgs.fetchzip {
  #       sha256 = "WwhDqywqIisDEsEbl6AfC1e47XvAMIauRyvnHhtymE4=";
  #       url = "https://github.com/nextcloud-releases/notes/releases/download/v4.7.2/notes.tar.gz";
  #     };
  #     texteditor = pkgs.fetchzip {
  #       sha256 = "Wvd5FhB0kAokaezqBK2QpfIDZgCVjmt1QO2SwSMJs2Y=";
  #       url = "https://github.com/nextcloud-releases/files_texteditor/releases/download/v2.15.0/files_texteditor.tar.gz";
  #     };
  #     tasks = pkgs.fetchzip {
  #       sha256 = "pbcw6bHv1Za+F351hDMGkMqeaAw4On8E146dak0boUo=";
  #       url = "https://github.com/nextcloud/tasks/releases/download/v0.14.5/tasks.tar.gz";
  #     };
  #   };
  # };

  # services.postgresql = {
  #   enable = true;
  #   ensureDatabases = ["nextcloud"];
  #   ensureUsers = [
  #     {
  #       name = "nextcloud";
  #       ensurePermissions."DATABASE nextcloud" = "ALL PRIVILEGES";
  #     }
  #   ];
  # };

  # # ensure that postgres is running *before* running the setup
  # systemd.services."nextcloud-setup" = {
  #   requires = ["postgresql.service"];
  #   after = ["postgresql.service"];
  # };

  sops.secrets.paperless-adminpass = {
    owner = "paperless";
    group = "paperless";
  };

  services.paperless = {
    enable = true;
    dataDir = "/var/lib/paperless";
    mediaDir = "/media/media/paperless/media";
    consumptionDir = "/media/media/paperless/consume";
    passwordFile = config.sops.secrets.paperless-adminpass.path;
  };

  sops.secrets.photoprism-adminpass = { };

  services.photoprism = {
    enable = true;
    originalsPath = "/media/media/photos";
    importPath = "/media/media/photos/import";
    passwordFile = config.sops.secrets.photoprism-adminpass.path;
  };

  # services.homepage-dashboard.enable = true;

  environment.etc.restic-ignore.text = ''
    .cache
    .Cache
    /var/lib/docker
    .rustup
    .spago
    .vscode
    Dropbox
    Google Drive
    Temp
    VirtualBox VMs
    node_modules
  '';
  systemd.services.restic-backups-dex.unitConfig.OnFailure = "notify-problems@%i.service";
  services.restic.backups = {
    dex = {
      paths = [
        "/home"
        "/root"
        "/media/media/home"
        "/mnt/services"
        "/mnt/downloader"
        "/var/lib"
        "/media/media/nextcloud"
        "/media/media/paperless"
        "/media/media/photos"
      ];
      repository = "/media/backup/restic";
      passwordFile = config.sops.secrets.restic-encryption.path;
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 4"
      ];
      extraBackupArgs = [
        "--exclude-file=/etc/restic-ignore"
        "--verbose"
        "2"
      ];
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
      };
    };
  };

  services.samba = {
    enable = true;
    settings = {
      global = {
        workgroup = "WORKGROUP";
        "server string" = "${params.hostname}";
        "netbios name" = "${params.hostname}";
        security = "user";
        #use sendfile = yes
        #max protocol = smb2
        "guest account" = "nobody";
        "map to guest" = "bad user";
      };
      homes = {
        browsable = "no";
        writable = "yes";
      };
      media = {
        path = "/media/media";
        browsable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
      };
      media2 = {
        path = "/media/media2";
        browsable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
      };
      games = {
        path = "/media/games";
        browsable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
      };
    };
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  services.kanata = {
    enable = false;
    keyboards = {
      laptop = {
        devices = [ "/dev/input/by-path/platform-i8042-serio-0-event-kbd" ];
        config = builtins.readFile ../../keymaps/kanata/engram.kbd;
      };
    };
  };
  system.stateVersion = "23.05"; # Did you read the comment?
}
