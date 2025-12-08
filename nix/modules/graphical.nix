{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
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
    xorg.xmodmap
    zathura
    zoom-us
  ];
}
