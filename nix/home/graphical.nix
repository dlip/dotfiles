{ pkgs, ... }:
{
  imports = [
    # ./vscode
  ];

  home.packages = with pkgs; [
    # audacity
    discord
    emoji-menu
    power-menu
    feh
    inkscape
    ghostty
    gimp
    kitty
    mlt
    # memento
    obsidian
    openscad
    qalculate-gtk
    slack
    xclip
    xmodmap
    zathura
    zoom-us
  ];
}
