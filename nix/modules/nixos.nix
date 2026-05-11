top@{
  withSystem,
  inputs,
  config,
  self,
  ...
}:
let
  mkHost =
    {
      hostname,
      system ? "x86_64-linux",
    }:
    {
      ${hostname} = inputs.nixpkgs.lib.nixosSystem rec {
        inherit system;
        specialArgs = {
          inherit inputs;
          inherit hostname;
        };
        modules = [
          (import ../systems/${hostname}/configuration.nix top)
          {
            nixpkgs.pkgs = withSystem system ({ pkgs, ... }: pkgs);
          }
        ];
      };

    };
in
{
  flake.nixosConfigurations = {
    ptv = inputs.nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ../systems/ptv/configuration.nix
        {
          nixpkgs.pkgs = withSystem system ({ pkgs, ... }: pkgs);
        }
      ];
    };
  }
  // (mkHost { hostname = "x"; })
  // (mkHost { hostname = "metabox"; })
  // (mkHost { hostname = "dex"; });
}
