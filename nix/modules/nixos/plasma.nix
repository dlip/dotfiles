{
  inputs,
  ...
}:
{
  flake.modules.nixos.plasma =
    { pkgs, ... }:
    {
      services.desktopManager.plasma6.enable = true;
      services.displayManager.plasma-login-manager.enable = true;
    };
}
