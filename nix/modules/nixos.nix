{
  withSystem,
  inputs,
  config,
  ...
}:
{
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
    x = inputs.nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      pkgs = withSystem system ({ pkgs, ... }: pkgs);
      modules = [
        config.flake.modules.nixos.hosts_x
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
  };
}
