{ pkgs, ... }:
with pkgs;
let
  default = [
    bash
    bat
    bc
    curl
    delta
    dig
    direnv
    entr
    fd
    findutils
    fontconfig
    fzf
    gcc
    gh
    gh-markdown-preview
    git
    gnugrep
    gnumake
    gnused
    gopls
    gotop
    htop
    iconv
    jq
    killall
    lazygit
    lsd
    lua-language-server
    markdownlint-cli2
    marksman
    ncdu
    ncurses
    neofetch
    neovim
    nettools
    nil
    nixfmt-rfc-style
    nmap
    openssh
    p7zip
    pciutils
    prettier
    pyright
    ripgrep
    ruff
    rust-analyzer
    shfmt
    sops
    speedread
    sqlite
    sshfs
    stack
    starship
    stylua
    tcpdump
    tmux
    tree
    tree-sitter
    unzip
    util-linux
    vim
    wget
    wireguard-tools
    yazi
    zip
    zoxide
    zsh
  ];
  extra = default ++ [
    # kdePackages.k3b # export QTWEBENGINE_DISABLE_SANDBOX=1; sudo -EH k3b
    # mimic
    # musikcube
    # myPythonPackages.adafruit-nrfutil
    # myPythonPackages.shirah-reader
    # ngrok
    # openvpn_aws
    # poetry
    # python311Packages.adafruit-nrfutil
    # python39Packages.grip
    # python39Packages.pip
    # python39Packages.pynvim
    # python39Packages.setuptools
    # rustc
    # rustup
    # steel
    # terminal-typeracer
    # turbo
    # visidata #broken
    # yubikey-manager #broken
    (lua.withPackages (ps: with ps; [ luacheck ]))
    (python3.withPackages (
      ps: with ps; [
        pyusb
        tkinter
      ]
    ))
    acpi
    age
    air
    android-tools
    ansifilter
    appimage-run
    archivemount
    autoreconfHook
    avrdude
    binutils
    blisp
    btop
    btop
    bun
    cargo
    cargo-wasi
    cheat
    clang-tools
    delve
    deno
    difftastic
    dive
    docker-buildx
    docker-compose
    eksctl
    evtest
    exiv2
    ffmpeg
    file
    fluxcd
    stable.fusee-launcher
    ghc
    glow
    gnupg
    gnuplot
    go
    gotypist
    gptfdisk
    graphviz
    hdparm
    hexdino
    hottext
    imagemagick
    iotop
    iputils
    jc
    jdk11
    joshuto
    jreadability
    k9s
    kaf
    kanata
    kind
    kmonad
    krename
    kubectl
    kubectx
    kubernetes-helm
    kubetail
    lldb
    lsof
    manga-tui
    massren
    mdbook
    mdl
    mecab
    mkvtoolnix-cli
    mysql80
    niv
    nix-du
    nix-index
    nix-init
    nodePackages.node2nix
    nodePackages.pnpm
    nodePackages.quicktype
    nodePackages.reveal-md
    nodePackages.typescript
    nodejs
    notify
    notify-desktop
    ns-usbloader
    nushell
    openssl
    openvpn
    pandoc
    patchelf
    pavucontrol
    php
    pinentry-curses
    postgresql
    pulseaudio
    pwgen
    qmk
    rclone
    redis
    # renameutils
    sd
    skopeo
    speedread
    ssh-to-age
    stable.awscli2
    stern
    strace
    tagainijisho
    tesseract
    texlive.combined.scheme-medium
    tio
    tiramisu
    tldr
    traceroute
    ttyper
    typespeed
    typioca
    unrar
    usbimager
    usbutils
    vegeta
    ventoy
    wasmtime
    wireshark-cli
    xdotool
    xorg.xhost # add root to xsession: xhost si:localuser:root
    yarn
    yarn2nix
    yq
    yt-dlp
    zgrviewer
    zoxide
  ];
  gui = extra ++ [
    # audacity
    # calibre # Test /get ... /nix/store/ncv68hjnidcd2bm5abkhklrijhn0cgn6-stdenv-linux/setup: line 1721: 20786 Segmentation fault      (core dumped) python setup.py test ${EXCLUDED_FLAGS[@]}
    # kicad-unstable
    # memento
    # obs-studio # sudo modprobe v4l2loopback devices=1 video_nr=21 card_label="OBS Cam" exclusive_caps=1
    # orca-slicer
    # plexamp
    # plover-dev
    # postman not found error
    # super-slicer-latest
    anki
    arandr
    blender
    brightnessctl
    cheese
    dbeaver-bin
    discord
    dragon-drop
    drawio
    droidcam
    easyeda2kicad
    easyeffects
    emoji-menu
    f3d
    feh
    firefox
    freecad
    fstl
    ghostty
    gimp
    google-chrome
    gparted
    gramps
    hakuneko
    helvum
    inkscape
    kdePackages.kdenlive
    keyd
    kitty
    kooha
    krita
    libreoffice
    mlt
    mpv
    neovide
    obsidian
    openscad
    plex-mpv-shim
    power-menu
    prusa-slicer
    pulsemixer
    qalculate-gtk
    remote-touchpad
    screenkey
    slack
    telegram-desktop
    v4l-utils
    via
    vial
    vlc
    warpd
    wasistlos # whatsapp-for-linux
    xclip
    xorg.xmodmap
    yacreader
    zathura
    zoom-us
  ];
  gaming = [
    # chiaki-ng
    # gamescope
    # minecraft
    # sidequest
    # wine64
    (stable.emulationstation-de { retroarch = retroarchWithCores; })
    alvr
    bottles
    cdecrypt
    cemu
    gamemode
    heroic
    igir
    lutris
    mame-tools
    mangohud
    maxcso
    mesa-demos
    moonlight-qt
    protontricks
    protonup-ng
    retool
    retroarchWithCores
    ryubing
    skyscraper
    vulkan-tools
    wine
    winetricks
    xemu
    xenia-canary
  ];
in
{
  inherit
    default
    extra
    gui
    gaming
    ;
}
