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
    cdecrypt
    cemu
    heroic
    igir
    lutris
    mame-tools
    mangohud
    maxcso
    moonlight-qt
    gamemode
    # gamescope
    protontricks
    protonup-ng
    # sidequest
    ra
    ryubing
    skyscraper
    (stable.emulationstation-de { retroarch = ra; })
    retool
    vulkan-tools
    wine
    # wine64
    winetricks
    xemu
    xenia-canary
  ];
}
