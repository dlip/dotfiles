{ withSystem, inputs, ... }:
{
  flake.nixosConfigurations = {
    dex = inputs.nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      modules = [
        ../systems/dex/configuration.nix
        {
          nixpkgs.pkgs = withSystem system ({ pkgs, ... }: pkgs);
        }
      ];
    };
    x = inputs.nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      pkgs = withSystem system ({ pkgs, ... }: pkgs);
      modules = [
        ../systems/x/configuration.nix
      ];
    };
    ptv = inputs.nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      modules = [
        ../systems/ptv/configuration.nix
        {
          nixpkgs.pkgs = withSystem system ({ pkgs, ... }: pkgs);
        }
      ];
    };
  };
}
