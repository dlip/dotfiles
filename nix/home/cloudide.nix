{ pkgs, ... }:
{
  home = {
    packages =
      with pkgs;
      groups.extra++ [
        valkey
        oci-cli
        devenv
      ];
    username = "byteide";
    homeDirectory = "/home/byteide";
    stateVersion = "26.05";
    sessionVariables = {
      SHELL = "${pkgs.zsh}/bin/zsh";
      LANG = "C.UTF-8";
      LC_ALL = "C.UTF-8";
    };
  };
  programs.home-manager.enable = true;
}
