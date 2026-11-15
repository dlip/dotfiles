{ self, inputs, ... }:
{
  pkgs,
  ...
}:
let
  downloader-services = import ./services.nix;
in
{
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    # sonarr
    "aspnetcore-runtime-wrapped-6.0.36"
    "aspnetcore-runtime-6.0.36"
    "dotnet-sdk-wrapped-6.0.428"
    "dotnet-sdk-6.0.428"
  ];

  nix = {
    # package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  environment.systemPackages = with pkgs; [
    traceroute
    vim
  ];
  networking = {
    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
      "8.8.4.4"
    ];
    firewall = {
      enable = true;
      allowedTCPPorts = pkgs.lib.attrsets.attrValues downloader-services;
      extraCommands = ''
        # The default policy, if no other rules match, is to refuse traffic.
        iptables -P OUTPUT DROP

        # Let the VPN client communicate with the outside world.
        iptables -A OUTPUT -p udp -m udp --dport 53 -j ACCEPT

        # The loopback device is harmless, and TUN is required for the VPN.
        iptables -A OUTPUT -j ACCEPT -o lo
        iptables -A OUTPUT -j ACCEPT -o tun+

        # Allow to communicate within the LAN
        iptables -A OUTPUT -s 10.1.0.0/24 -d 10.1.0.0/24 -j ACCEPT
      '';
    };
  };

  # qbittorrent stops downloading when vpn gets reconnected
  systemd.services.restart-qbittorrent = {
    enable = true;
    description = "Restart qbittorrent";

    serviceConfig = {
      Type = "oneshot";
      User = "root";
      Group = "root";
    };
    script = ''
      systemctl restart qbittorrent
    '';
  };

  systemd.timers.restart-qbittorrent = {
    wantedBy = [ "timers.target" ];
    partOf = [ "restart-qbittorrent.service" ];
    timerConfig = {
      OnActiveSec = "4h";
      OnUnitActiveSec = "4h";
    };
  };

  services.openvpn.servers = {
    nordvpn = {
      updateResolvConf = true;
      config = "config /mnt/services/openvpn/nordvpn.ovpn";
    };
  };

  systemd.services.transmission = {
    bindsTo = [ "openvpn-nordvpn.service" ];
    after = [ "openvpn-nordvpn.service" ];
    serviceConfig.Restart = "always";
  };

  services.sonarr = {
    enable = true;
    user = "root";
    group = "root";
  };
  services.radarr = {
    enable = true;
    user = "root";
    group = "root";
  };
  services.lidarr = {
    enable = true;
    user = "root";
    group = "root";
  };
  services.readarr = {
    enable = true;
    user = "root";
    group = "root";
  };
  services.bazarr = {
    enable = true;
  };

  services.prowlarr = {
    enable = true;
  };

  services.qbittorrent = {
    enable = true;
    user = "root";
    group = "root";
  };

  services.qui = {
    enable = true;
    secretFile = "/var/lib/qui/session-secret";
    settings = {
      host = "0.0.0.0";
      port = downloader-services.qui;
      sessionCookieSecure = true;
    };
  };

  systemd.services.qui = {
    requires = [ "qui-session-secret.service" ];
    after = [ "qui-session-secret.service" ];
  };

  systemd.services.qui-session-secret = {
    description = "Initialize Qui session secret";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = "qui";
      Group = "qui";
      StateDirectory = "qui";
      StateDirectoryMode = "0700";
      UMask = "0077";
    };
    script = ''
      if [ ! -s /var/lib/qui/session-secret ]; then
        ${pkgs.openssl}/bin/openssl rand -hex 32 > /var/lib/qui/session-secret
      fi
    '';
  };

  # services.suwayomi-server = {
  #   enable = true;
  #   user = "root";
  #   group = "root";
  #   dataDir = "/media/media/manga";
  #   settings = {
  #     server.port = 4567;
  #   };
  # };

  system.stateVersion = "23.05";
}
