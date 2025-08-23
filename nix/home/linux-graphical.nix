{
  pkgs,
  ...
}:
{
  imports = [
    # ./hyprland.nix
    ./niri.nix
    ./graphical.nix
    ./desktop-entries.nix
  ];

  home.packages = with pkgs; [
    anki
    arandr
    brightnessctl
    blender
    # calibre # Test /get ... /nix/store/ncv68hjnidcd2bm5abkhklrijhn0cgn6-stdenv-linux/setup: line 1721: 20786 Segmentation fault      (core dumped) python setup.py test ${EXCLUDED_FLAGS[@]}
    cheese
    dbeaver-bin
    drawio
    droidcam
    easyeda2kicad
    easyeffects
    gparted
    gramps
    f3d
    firefox
    freecad-wayland
    fstl
    hakuneko
    helvum
    keyd
    kdePackages.kdenlive
    kooha
    krita
    # kicad-unstable
    libreoffice
    mpv
    neovide
    # obs-studio # sudo modprobe v4l2loopback devices=1 video_nr=21 card_label="OBS Cam" exclusive_caps=1
    v4l-utils
    # plover-dev
    pulsemixer
    # plexamp
    # postman not found error
    remote-touchpad
    screenkey
    # orca-slicer
    # super-slicer-latest
    prusa-slicer
    tdesktop
    via
    vial
    vlc
    warpd
    whatsapp-for-linux
    xdragon
    yacreader
  ];
}
