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

      model = pkgs.whisper-ggml-model.override {
        inherit (cfg) model;
        hash = cfg.modelHash;
      };

      whisperServer = pkgs.whisper-cpp.override { cudaSupport = cfg.cuda; };

      # whisrs talks to whisper-server through its generic `asr-sidecar`
      # backend, which needs no patching: whisrs POSTs multipart `file` +
      # `model` + `language` and parses `{"text": ...}`, and whisper-server's
      # /inference requires `file`, accepts `language`, and returns exactly
      # that shape when response_format is json (its default).
      #
      # Two harmless mismatches: `model` is ignored on /inference (it belongs
      # to /load, and the model is fixed at launch below), and whisrs sends the
      # vocabulary as `hotwords` where whisper-server expects `prompt`, so
      # `vocabulary`/`prompt` in whisrs config has no effect on this backend.
      configToml = pkgs.writeText "whisrs-config.toml" ''
        [general]
        backend = "asr-sidecar"
        language = "en"
        notify = true
        remove_filler_words = true
        audio_feedback = true
        audio_feedback_volume = 0.4
        tray = true
        overlay = true

        [overlay]
        theme = "carbon"

        [audio]
        device = "default"

        [asr-sidecar]
        url = "http://127.0.0.1:${toString cfg.port}/inference"
        model = "${cfg.model}"
      '';
    in
    {
      options.services.whisrs = {
        enable = lib.mkEnableOption "whisrs voice dictation daemon";

        user = lib.mkOption {
          type = lib.types.str;
          description = "User whose session runs the whisrs daemon.";
        };

        cuda = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = ''
            Build whisper-cpp with CUDA for GPU decoding. Needs a working
            NVIDIA driver; on a PRIME-offload laptop the discrete GPU must not
            be fully powered down (`powerManagement.finegrained = false`).
          '';
        };

        port = lib.mkOption {
          type = lib.types.port;
          default = 8080;
          description = "Loopback port for the whisper-server sidecar.";
        };

        model = lib.mkOption {
          type = lib.types.str;
          default = "base.en";
          example = "small.en";
          description = ''
            whisper.cpp GGML model: tiny.en (75MB), base.en (142MB),
            small.en (466MB), medium.en (1.5GB). Larger is more accurate and
            slower. Changing this needs a matching `modelHash`.
          '';
        };

        modelHash = lib.mkOption {
          type = lib.types.str;
          default = "sha256-oDd5yG3zMjB19eeWyyzlAp8A7Ihp7uP9+4l6/jbG0AI=";
          description = ''
            SRI hash of the GGML model file. Get it with:
            nix store prefetch-file https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-<model>.bin
          '';
        };
      };

      config = lib.mkIf cfg.enable {
        environment.systemPackages = [
          pkgs.whisrs
          whisperServer
        ];

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

        # Transcription sidecar. Bound to loopback only — the HTTP API has no
        # authentication, so it must not be exposed. System-wide rather than a
        # user service since it holds the model in memory and has no dependency
        # on the graphical session.
        systemd.services.whisper-server = {
          description = "whisper.cpp HTTP transcription server (whisrs sidecar)";
          wantedBy = [ "multi-user.target" ];
          after = [ "network.target" ];

          serviceConfig = {
            ExecStart = lib.concatStringsSep " " [
              "${whisperServer}/bin/whisper-server"
              "--model ${model}"
              "--host 127.0.0.1"
              "--port ${toString cfg.port}"
              # Stops "(silence)" / "[BLANK_AUDIO]" style artefacts being typed
              # at the cursor when a phrase is mostly quiet.
              "--suppress-nst"
            ];
            Restart = "on-failure";
            RestartSec = 3;

            DynamicUser = true;
            # Model is a world-readable store path, so no extra access needed.
            ProtectSystem = "strict";
            ProtectHome = true;
            PrivateTmp = true;
            NoNewPrivileges = true;
            RestrictAddressFamilies = [
              "AF_INET"
              "AF_UNIX"
            ];
          }
          // lib.optionalAttrs cfg.cuda {
            # CUDA needs the NVIDIA device nodes and the driver libraries, which
            # ProtectSystem=strict would otherwise hide.
            PrivateDevices = false;
            DeviceAllow = [
              "/dev/nvidia0 rw"
              "/dev/nvidiactl rw"
              "/dev/nvidia-uvm rw"
              "/dev/nvidia-uvm-tools rw"
              "/dev/nvidia-modeset rw"
            ];
          };
        };

        # Config lives at the path whisrs hardcodes ($XDG_CONFIG_HOME/whisrs).
        # 0600 matches what `whisrs setup` writes; it holds no secrets on the
        # sidecar backend, but `whisrs config` expects that mode.
        systemd.user.services.whisrs = {
          description = "whisrs dictation daemon";
          documentation = [ "https://github.com/y0sif/whisrs" ];
          partOf = [ "graphical-session.target" ];
          after = [ "graphical-session.target" ];
          wantedBy = [ "niri.service" ];

          # Window tracking shells out to `niri msg --json focused-window`, so
          # the daemon needs niri on PATH. niri-session runs
          # `systemctl --user import-environment`, which puts NIRI_SOCKET and
          # WAYLAND_DISPLAY into the user manager's environment before
          # niri.service pulls this unit in.
          path = [ config.programs.niri.package ];

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
