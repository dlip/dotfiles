{ pkgs, ... }:
let
  ra = (
    pkgs.retroarch.withCores (
      cores: with cores; [
        genesis-plus-gx
        snes9x
        beetle-psx-hw
        mesen
        nestopia
        fceumm
        mame
        fbneo
      ]
    )
  );
in
{
  home.packages = with pkgs; [
    alvr
    # chiaki-ng
    # minecraft
    bottles
    heroic
    lutris
    mangohud
    moonlight-qt
    gamemode
    # gamescope
    protontricks
    protonup
    sidequest
    ra
    (stable.emulationstation-de { retroarch = ra; })
    vulkan-tools
    wine
    # wine64
    winetricks
  ];
}
