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
  flake.nixosConfigurations = { }
  # // (mkHost { hostname = "ptv"; }) # TODO: uncomment after adding traefik-env to ptv secrets
  // (mkHost { hostname = "x"; })
  // (mkHost { hostname = "metabox"; })
  // (mkHost { hostname = "dex"; });
}
