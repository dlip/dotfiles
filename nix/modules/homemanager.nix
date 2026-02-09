{ withSystem, inputs, ... }:
{
  # nix run home-manager/master -- switch --flake .#docker
  flake.homeConfigurations = {
    docker = inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = withSystem "x86_64-linux" ({ pkgs, ... }: pkgs);
      modules = [ ../home/docker.nix ];
    };
    docker-arm = inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = withSystem "aarch64-linux" ({ pkgs, ... }: pkgs);
      modules = [ ../home/docker.nix ];
    };
  };
}
