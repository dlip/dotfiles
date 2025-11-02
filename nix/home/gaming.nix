{ pkgs, ... }:
{
  home.packages = with pkgs; [
    alvr
    # chiaki-ng
    # minecraft
    # bottles
    heroic
    lutris
    mangohud
    gamemode
    protontricks
    protonup
    sidequest
    vulkan-tools
    # wine
    wine64
    winetricks
  ];
}
