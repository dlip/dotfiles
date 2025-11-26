{ pkgs, ... }:
let
  ra = (
    pkgs.retroarch.withCores (
      cores: with cores; [
        beetle-psx
        beetle-psx-hw
        fbneo
        freeintv
        gambatte
        genesis-plus-gx
        mame
        melonds
        mesen
        mgba
        mupen64plus
        picodrive
        ppsspp
        snes9x
        stella
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
    igir
    lutris
    mangohud
    moonlight-qt
    gamemode
    # gamescope
    protontricks
    protonup
    # sidequest
    ra
    (stable.emulationstation-de { retroarch = ra; })
    retool
    vulkan-tools
    wine
    # wine64
    winetricks
  ];
}
