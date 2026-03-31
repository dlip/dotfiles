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
            "ventoy-1.1.10"
          ];
        };
        overlays = [
          inputs.nix-on-droid.overlays.default
          inputs.nixgl.overlay
          # helix.overlays.default
          # poetry2nix.overlay
          # packages
          (final: prev: {
            # actualServer = final.callPackage ../pkgs/actualServer {
            #   src = actual-server;
            #   nodejs = final.nodejs-16_x;
            # };
            # vscodeNodeDebug2 = final.callPackage ../pkgs/vscodeNodeDebug2 {src = vscodeNodeDebug2;};

            mokuro-reader = inputs.mokuro-reader.packages.${final.stdenv.hostPlatform.system}.default;
            bottles = (prev.bottles.override { removeWarningPopup = true; });
            emoji-menu = final.writeShellScriptBin "emoji-menu" (
              builtins.readFile "${inputs.emoji-menu}/bin/emoji-menu"
            );

            groups = final.callPackage ../pkgs/groups.nix { };
            # myEspanso = final.callPackage ../pkgs/espanso {};
            # hyprland = hyprland.packages.${final.stdenv.hostPlatform.system}.hyprland;
            # hyprcursor-catppuccin = hyprcursor-catppuccin.packages.${final.stdenv.hostPlatform.system}.hyprcursor-catppuccin;
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
          })
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
