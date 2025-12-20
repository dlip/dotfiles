inputs@{
  # , poetry2nix
  # actual-server,
  emoji-menu,
  power-menu,
  # helix,
  sops-nix,
  nix-on-droid,
  # vscodeNodeDebug2,
  # nixvim,
  # hyprland,
  # hyprcursor-catppuccin,
  niri-flake,
  nixgl,
  mokuro-reader,
  ...
}:
[
  nix-on-droid.overlays.default
  nixgl.overlay
  # helix.overlays.default
  # poetry2nix.overlay
  # packages
  (final: prev: {
    inherit sops-nix niri-flake;
    # actualServer = final.callPackage ./actualServer {
    #   src = actual-server;
    #   nodejs = final.nodejs-16_x;
    # };
    # vscodeNodeDebug2 = final.callPackage ./vscodeNodeDebug2 {src = vscodeNodeDebug2;};

    mokuro-reader = mokuro-reader.packages.${final.stdenv.hostPlatform.system}.default;
    bottles = (prev.bottles.override { removeWarningPopup = true; });
    emoji-menu = final.writeShellScriptBin "emoji-menu" (
      builtins.readFile "${emoji-menu}/bin/emoji-menu"
    );

    groups = final.callPackage ./groups.nix { };
    # myEspanso = final.callPackage ./espanso {};
    # hyprland = hyprland.packages.${final.stdenv.hostPlatform.system}.hyprland;
    # hyprcursor-catppuccin = hyprcursor-catppuccin.packages.${final.stdenv.hostPlatform.system}.hyprcursor-catppuccin;
    power-menu = final.writeShellScriptBin "power-menu" (
      builtins.readFile "${power-menu}/rofi-power-menu"
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

    myNodePackages = final.callPackage ./nodePackages { };
    # myPythonPackages = final.callPackage ./pythonPackages { };
    skyscraper = final.callPackage ./skyscraper { };
    # solang = final.callPackage ./solang { };
    jreadability = final.callPackage ./jreadability/package.nix { };
    # juliusSpeech = final.callPackage ./juliusSpeech { };
    # talon = final.callPackage ./talon { };
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
]
