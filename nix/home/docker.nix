{ pkgs, ... }:
{
  home = {
    packages =
      with pkgs;
      pkgs.groups.default
      ++ [
        ncurses
      ];
    username = "root";
    homeDirectory = "/root";
    stateVersion = "26.05";
    sessionVariables = {
      TERMINFO_DIRS = "${pkgs.ncurses}/share/terminfo:${pkgs.kitty}/lib/kitty/terminfo:$HOME/.nix-profile/share/terminfo:/usr/share/terminfo";
      TERM = "kitty";
      SHELL = "${pkgs.zsh}/bin/zsh";
      LANG = "C.UTF-8";
      LC_ALL = "C.UTF-8";
    };
  };
  programs.home-manager.enable = true;
}
