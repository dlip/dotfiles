{
  ...
}:
{
  flake.modules.nixos.whisrs =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.services.whisrs;

      model = pkgs.whisper-ggml-model;

      # whisrs does NOT expand `~` in model_path — src/lib.rs checks
      # `Path::new(&model_path).exists()` verbatim, so this must be absolute.
      # Pointing at the store path also means the model is deployed with the
      # system rather than downloaded by `whisrs setup`.
      configToml = pkgs.writeText "whisrs-config.toml" ''
        [general]
        backend = "local-whisper"
        language = "en"
        notify = true
        remove_filler_words = true
        audio_feedback = true
        audio_feedback_volume = 0.4
        tray = true
        overlay = true
        vocabulary = ["niri", "nixpkgs", "NixOS", "whisrs", "kanata", "zellij", "sops"]

        [overlay]
        theme = "carbon"

        [audio]
        device = "default"

        [local-whisper]
        model_path = "${model}"
        segmentation = "silence"
        phrase_silence_ms = 400
      '';
    in
    {
      options.services.whisrs = {
        enable = lib.mkEnableOption "whisrs voice dictation daemon";

        user = lib.mkOption {
          type = lib.types.str;
          description = "User whose session runs the whisrs daemon.";
        };
      };

      config = lib.mkIf cfg.enable {
        environment.systemPackages = [ pkgs.whisrs ];

        # whisrs synthesises keystrokes through /dev/uinput.
        hardware.uinput.enable = true;
        users.users.${cfg.user}.extraGroups = [
          "input"
          "uinput"
        ];

        # Upstream's contrib/99-whisrs.rules hardcodes /usr/bin/setfacl, which
        # does not exist on NixOS; its own comment tells packagers to rewrite
        # the path. The TEST== guard makes the rule a no-op otherwise, which
        # would silently leave /dev/uinput unwritable if another rule (brltty)
        # has set an ACL on it.
        services.udev.extraRules = ''
          KERNEL=="uinput", SUBSYSTEM=="misc", MODE="0660", GROUP="input", TAG+="uaccess"
          KERNEL=="uinput", SUBSYSTEM=="misc", RUN+="${pkgs.acl}/bin/setfacl -m g:input:rw /dev/$name"
        '';

        # Config lives at the path whisrs hardcodes ($XDG_CONFIG_HOME/whisrs).
        # 0600 matches what `whisrs setup` writes; it holds no secrets on the
        # local backend, but `whisrs config` expects that mode.
        systemd.user.services.whisrs = {
          description = "whisrs dictation daemon";
          documentation = [ "https://github.com/y0sif/whisrs" ];
          partOf = [ "graphical-session.target" ];
          after = [ "graphical-session.target" ];
          wantedBy = [ "niri.service" ];

          # Window tracking shells out to `niri msg --json focused-window`, so
          # the daemon needs niri on PATH and NIRI_SOCKET in its environment.
          # niri-session runs `systemctl --user import-environment`, which puts
          # NIRI_SOCKET and WAYLAND_DISPLAY into the user manager's environment
          # before niri.service pulls this unit in.
          path = [
            config.programs.niri.package
            pkgs.acl
          ];

          serviceConfig = {
            Type = "simple";
            ExecStartPre = pkgs.writeShellScript "whisrs-config" ''
              install -d -m700 "''${XDG_CONFIG_HOME:-$HOME/.config}/whisrs"
              install -m600 ${configToml} "''${XDG_CONFIG_HOME:-$HOME/.config}/whisrs/config.toml"
            '';
            ExecStart = "${pkgs.whisrs}/bin/whisrsd";
            Restart = "on-failure";
            RestartSec = 3;
          };
        };
      };
    };
}
