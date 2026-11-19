{ inputs, ... }:
{
  flake.modules.nixos.umbriel = {
    imports = [ inputs.umbriel.nixosModules.default ];

    programs.umbriel.enable = true;

    nix.settings = {
      extra-substituters = [ "https://umbriel.cachix.org" ];
      extra-trusted-public-keys = [
        "umbriel.cachix.org-1:JfNq/2yg2S6D6z4Z2dVSZrZlDPQTKtexB6GAVLD98nw="
      ];
    };
  };
}
