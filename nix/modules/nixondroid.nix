{ withSystem, inputs, ... }:
{
  # nix-on-droid switch --flake .#default
  flake.nixOnDroidConfigurations.default = inputs.nix-on-droid.lib.nixOnDroidConfiguration {
    pkgs = withSystem "aarch64-linux" ({ pkgs, ... }: pkgs);
    modules = [ ../systems/nix-on-droid/configuration.nix ];
  };
}
