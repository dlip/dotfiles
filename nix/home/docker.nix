{ pkgs, ... }:
{
  home = {
    packages = pkgs.groups.default;
    username = "root";
    homeDirectory = "/root";
    stateVersion = "26.05";
  };
programs.home-manager.enable = true;
}
