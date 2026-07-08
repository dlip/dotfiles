{ pkgs, ... }:
with pkgs;
let
  lsp = [
    gopls
    lua-language-server
    markdownlint-cli2
    marksman
    nil
    nixd
    nixfmt
    ruff
    rust-analyzer
    shfmt
    stylua
    tree-sitter
  ];
  default = lsp ++ [
    bash
    bat
    bc
    curl
    delta
    dig
    direnv
    entr
    fastfetch
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
    gotop
    htop
    iconv
    jq
    killall
    lazygit
    lsd
    ncdu
    ncurses
    neovim
    nettools
    nmap
    openssh_gssapi
    p7zip
    pciutils
    prettier
    pyright
    ripgrep
    sops
    speedread
    sqlite
    sshfs
    stack
    starship
    tcpdump
    tmux
    tree
    tree-sitter
    unzip
    util-linux
    uv
    vim
    wget
    wireguard-tools
    yazi
    zip
    zoxide
    zsh
  ];
  extra = default ++ [
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
    claude-code
    delve
    deno
    devenv
    difftastic
    dive
    docker-buildx
    docker-compose
    eksctl
    evtest
    exiv2
    f3
    ffmpeg
    file
    fluxcd
    fusee-launcher
    ghc
    glow
    gnupg
    gnuplot
    go
    gotypist
    gptfdisk
    graphviz
    hdparm
    unstable.herdr
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
    niv
    nix-du
    nix-index
    nix-init
    nodejs
    notify
    notify-desktop
    ns-usbloader
    nushell
    opencode
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
    # renameutils
    sd
    skopeo
    speedread
    ssh-to-age
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
    typioca
    unrar
    usbimager
    usbutils
    valkey
    vegeta
    # ventoy
    wasmtime
    wireshark-cli
    xdotool
    xhost # add root to xsession: xhost si:localuser:root
    yarn
    yq
    yt-dlp
    zgrviewer
    zoxide
  ];
  gui = extra ++ [
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
    audacity
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
    inkscape
    karere # whatsapp-for-linux
    # kdePackages.kdenlive
    keyd
    kitty
    kooha
    krita
    libreoffice-fresh
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
    thorium-reader
    v4l-utils
    via
    vial
    vlc
    warpd
    xclip
    xmodmap
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
    # (emulationstation-de { retroarch = retroarchWithCores; })
    alvr
    bottles
    cdecrypt
    # cemu
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
    # ryubing
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
