{
  withSystem,
  inputs,
  config,
  self,
  ...
}:
let
  mkHost =
    {
      name,
      system ? "x86_64-linux",
    }:
    {
      ${name} = inputs.nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          (import ../systems/${name}/configuration.nix self)
          {
            nixpkgs.pkgs = withSystem system ({ pkgs, ... }: pkgs);
          }
        ];
      };

    };
in
{
  flake.modules.nixos.hosts_x = (import ../systems/x/configuration.nix self);
  flake.nixosConfigurations = {
    dex = inputs.nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ../systems/dex/configuration.nix
        {
          nixpkgs.pkgs = withSystem system ({ pkgs, ... }: pkgs);
        }
      ];
    };
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
  // (mkHost { name = "x"; });
}
