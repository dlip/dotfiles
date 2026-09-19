{ inputs, ... }:
{
  systems = [
    "x86_64-linux"
    "aarch64-linux"
  ];
  perSystem =
    { system, ... }:
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          permittedInsecurePackages = [
            # opentabletdriver
            "dotnet-runtime-6.0.36"
            "dotnet-sdk-wrapped-6.0.428"
            "dotnet-sdk-6.0.428"
            "libsoup-2.74.3"
            "freeimage-3.18.0-unstable-2024-04-18"
            "ventoy-1.1.12"
            "pnpm-9.15.9"
          ];
        };
        overlays = [
          inputs.storyteller.overlays.default
          inputs.nix-on-droid.overlays.default
          inputs.nixgl.overlay
          # helix.overlays.default
          # poetry2nix.overlay
          # packages
          (
            final: prev:
            let
              # LiteLLM 1.97.0 has two regressions relevant here: it imports
              # get_flat_dependant from FastAPI and its chatgpt/* bridge breaks
              # non-streaming chat completions. Keep the known-good 1.89.5
              # release and its FastAPI stack on 0.140.1.
              fastapiOlder = final.python314Packages.fastapi.overrideAttrs (_: {
                version = "0.140.1";
                src = final.fetchPypi {
                  pname = "fastapi";
                  version = "0.140.1";
                  hash = "sha256-jBD3XPF8RvnSfFEqb5vMNkP/7yApqayVb4v4Ie9Hzuo=";
                };
              });
              fastapiSsoOlder = final.python314Packages.fastapi-sso.overridePythonAttrs (old: {
                dependencies = map (
                  dep: if (dep.pname or null) == "fastapi" then fastapiOlder else dep
                ) old.dependencies;
              });
              litellmOlder = prev.litellm.overridePythonAttrs (old: {
                version = "1.89.5";
                src = final.fetchFromGitHub {
                  owner = "BerriAI";
                  repo = "litellm";
                  tag = "v1.89.5";
                  hash = "sha256-qRoRxoSvJh+0KD74JRzhA3YsAQa6X8qiyPvPfUuBdhY=";
                };
                cargoRoot = null;
                cargoDeps = null;
                nativeBuildInputs = builtins.filter (
                  input:
                  !builtins.elem (input.pname or "") [
                    "cargo-setup-hook.sh"
                    "maturin-build-hook.sh"
                  ]
                ) old.nativeBuildInputs ++ [ final.python314Packages.uv-build ];
                postPatch = ''
                  substituteInPlace pyproject.toml \
                    --replace-fail "uv_build==0.11.8" "uv_build==${final.python314Packages.uv-build.version}"
                '';
              });
            in
            {
              # actualServer = final.callPackage ../pkgs/actualServer {
              #   src = actual-server;
              #   nodejs = final.nodejs-16_x;
              # };
              # vscodeNodeDebug2 = final.callPackage ../pkgs/vscodeNodeDebug2 {src = vscodeNodeDebug2;};

              # tempfix https://github.com/NixOS/nixpkgs/issues/554550
              # karakeep = final.callPackage "${inputs.nixpkgs}/pkgs/by-name/ka/karakeep/package.nix" {
              #   # Avoid nodejs 24 while waiting on bugfix for https://github.com/karakeep-app/karakeep/issues/2989
              #   nodejs = final.nodejs_22;
              # };
              # https://github.com/NixOS/nixpkgs/issues/514113
              openldap = prev.openldap.overrideAttrs {
                doCheck = !prev.stdenv.hostPlatform.isi686;
              };
              mokuro-reader = inputs.mokuro-reader.packages.${final.stdenv.hostPlatform.system}.default;
              bottles = (prev.bottles.override { removeWarningPopup = true; });

              litellm = litellmOlder.overridePythonAttrs (old: {
                dependencies = map (
                  dep:
                  if (dep.pname or null) == "fastapi" then
                    fastapiOlder
                  else if (dep.pname or null) == "fastapi-sso" then
                    fastapiSsoOlder
                  else
                    dep
                ) old.dependencies;
              });

              emulationstation-de = final.callPackage ../pkgs/emulationstation-de { };
              emoji-menu = final.writeShellScriptBin "emoji-menu" (
                builtins.readFile "${inputs.emoji-menu}/bin/emoji-menu"
              );

              freeimage = final.callPackage ../pkgs/freeimage/package.nix { };
              # libjpeg_turbo = final.callPackage ../pkgs/libjpeg-turbo/package.nix { };
              fusee-launcher = final.callPackage ../pkgs/fusee-launcher/package.nix { };
              groups = final.callPackage ../pkgs/groups.nix { };
              # myEspanso = final.callPackage ../pkgs/espanso {};
              # hyprland = hyprland.packages.${final.stdenv.hostPlatform.system}.hyprland;
              # hyprcursor-catppuccin = hyprcursor-catppuccin.packages.${final.stdenv.hostPlatform.system}.hyprcursor-catppuccin;
              hermes-agent = inputs.hermes-agent.packages.${final.stdenv.hostPlatform.system}.default.override {
                extraPythonPackages = with final; [ python312Packages.python-telegram-bot ];
              };
              hermes-desktop = inputs.hermes-agent.packages.${final.stdenv.hostPlatform.system}.desktop;
              power-menu = final.writeShellScriptBin "power-menu" (
                builtins.readFile "${inputs.power-menu}/rofi-power-menu"
              );
              nnn = prev.nnn.overrideAttrs (oldAttrs: {
                makeFlags = oldAttrs.makeFlags ++ [ "O_NERD=1" ];
              });

              # nixvim = nixvim.legacyPackages.${final.stdenv.hostPlatform.system}.makeNixvimWithModule {
              #   module = import ./nixvim;
              #   extraSpecialArgs = {
              #     extraPluginsSrc = final.lib.filterAttrs (n: v: final.lib.hasPrefix "vimplugin-" n) inputs;
              #   };
              # };

              retroarchWithCores = (
                final.retroarch.withCores (
                  cores: with cores; [
                    beetle-psx
                    beetle-psx-hw
                    dosbox-pure
                    fbneo
                    freeintv
                    gambatte
                    genesis-plus-gx
                    mame
                    melonds
                    mesen
                    mgba
                    mupen64plus
                    picodrive
                    ppsspp
                    snes9x
                    stella
                  ]
                )
              );
              rofimoji = prev.rofimoji.overrideAttrs (oldAttrs: {
                rofi = final.rofi;
              });
              # helix = helix.packages.${final.stdenv.hostPlatform.system}.default;

              myNodePackages = final.callPackage ../pkgs/nodePackages { };
              # myPythonPackages = final.callPackage ../pkgs/pythonPackages { };
              skyscraper = final.callPackage ../pkgs/skyscraper { };
              # solang = final.callPackage ../pkgs/solang { };
              jreadability = final.callPackage ../pkgs/jreadability/package.nix { };
              # Stock upstream build: CPU-only and cheap, because GPU decoding is
              # done by whisper-cpp via the asr-sidecar backend rather than by
              # whisrs's own vendored whisper.cpp.
              whisrs = inputs.whisrs.packages.${final.stdenv.hostPlatform.system}.default;
              whisper-ggml-model = final.callPackage ../pkgs/whisper-ggml-model { };
              # juliusSpeech = final.callPackage ../pkgs/juliusSpeech { };
              # talon = final.callPackage ../pkgs/talon { };
              # inherit (final.callPackages "${openvpn-aws}/derivations/openvpn.nix" { }) openvpn_aws;
              # freecad fix https://github.com/NixOS/nixpkgs/issues/429237
              # coin3d = prev.coin3d.overrideAttrs {
              #   src = final.fetchFromGitHub {
              #     owner = "coin3d";
              #     repo = "coin";
              #     rev = "v4.0.3";
              #     hash = "sha256-dUFmcUOdNc3ZFtr+Hnh3Q3OY/JA/WxmiRJiU2RFSSus=";
              #   };
              # };
            }
          )
          # Repos with no build step
          (final: prev: prev.lib.filterAttrs (k: v: prev.lib.hasPrefix "repo" k) inputs)
          # vim plugins
          (final: prev: {
            vimPlugins =
              prev.vimPlugins
              // builtins.listToAttrs (
                map (
                  input:
                  let
                    name = final.lib.removePrefix "vimplugin-" input;
                  in
                  {
                    inherit name;
                    value = final.vimUtils.buildVimPlugin {
                      inherit name;
                      pname = name;
                      src = builtins.getAttr input inputs;
                    };
                  }
                ) (builtins.attrNames (final.lib.filterAttrs (k: v: final.lib.hasPrefix "vimplugin" k) inputs))
              );
          })
          (final: prev: {
            stable = import inputs.nixpkgs-stable {
              inherit system;
              config = {
                allowUnfree = true;
                permittedInsecurePackages = [
                  "freeimage-3.18.0-unstable-2024-04-18"
                  "pnpm-9.15.9"
                ];
              };
              overlays = [
                (final: prev: {
                  emulationstation-de = final.callPackage ../pkgs/emulationstation-de { };
                })
              ];
            };
            cudaPkgs = import inputs.nixpkgs {
              inherit system;
              config = {
                allowUnfree = true;
                cudaSupport = true;
              };
            };
          })
        ];
      };
    };
}
