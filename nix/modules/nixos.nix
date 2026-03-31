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
      name,
      system ? "x86_64-linux",
    }:
    {
      ${name} = inputs.nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          (import ../systems/${name}/configuration.nix top)
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
  // (mkHost { name = "x"; })
  // (mkHost { name = "dex"; });
}
