{
  pkgs,
  ...
}: {
  imports = [
    ./hyprland.nix
    ./graphical.nix
    ./desktop-entries.nix
  ];

  home.packages = with pkgs; [
    anki
    alttab
    arandr
    brightnessctl
    blender
    # calibre # Test /get ... /nix/store/ncv68hjnidcd2bm5abkhklrijhn0cgn6-stdenv-linux/setup: line 1721: 20786 Segmentation fault      (core dumped) python setup.py test ${EXCLUDED_FLAGS[@]}
    dbeaver-bin
    drawio
    easyeffects
    gparted
    gramps
    f3d
    firefox
    freecad
    fstl
    helvum
    keyd
    kdenlive
    kooha
    krita
    kicad-unstable
    libreoffice
    mpv
    neovide
    obs-studio # sudo modprobe v4l2loopback devices=1 video_nr=21 card_label="OBS Cam" exclusive_caps=1
    v4l-utils
    # plover.dev
    pulsemixer
    # plexamp
    # postman not found error
    remote-touchpad
    screenkey
    # orca-slicer
    # super-slicer-latest
    prusa-slicer
    tdesktop
    vlc
    warpd
    whatsapp-for-linux
    xdragon
    yacreader
  ];
}
