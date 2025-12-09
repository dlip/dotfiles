{ pkgs, ... }:
let
  default = with pkgs; [
    gh-markdown-preview
    gopls
    markdownlint-cli2
    marksman
    nil
    nixfmt-rfc-style
    prettier
    pyright
    ruff
    rust-analyzer
    shfmt
    stylua
    lua-language-server
    tree-sitter
    font-awesome
    fontconfig
    hachimarupop
    hanazono
    noto-fonts
    noto-fonts-cjk-sans
    nerd-fonts.fira-code
    nerd-fonts.droid-sans-mono
    nerd-fonts.roboto-mono
    nerd-fonts.sauce-code-pro
    cargo
    bat
    bc
    curl
    delta
    dig
    direnv
    entr
    fd
    findutils
    fzf
    gcc
    gh
    git
    gnugrep
    gnumake
    gotop
    htop
    iconv
    jq
    killall
    lazygit
    lsd
    ncdu
    ncurses
    neofetch
    nettools
    neovim
    nmap
    p7zip
    ripgrep
    gnused
    openssh
    speedread
    sops
    sqlite
    sshfs
    stack
    starship
    tcpdump
    tmux
    tree
    unzip
    util-linux
    wget
    wireguard-tools
    yazi
    zip
    zoxide
    zsh
  ];
  extra =
    with pkgs;
    default
    ++ [
      acpi
      appimage-run
      binutils
      btop
      # mimic
      btop
      evtest
      hdparm
      # fusee-launcher
      iotop
      iputils
      kanata
      # kdePackages.k3b # export QTWEBENGINE_DISABLE_SANDBOX=1; sudo -EH k3b
      kmonad
      krename
      mecab
      mkvtoolnix-cli
      # nix-du
      ns-usbloader
      pinentry-curses
      # python311Packages.adafruit-nrfutil
      qmk
      strace
      tagainijisho
      tiramisu
      traceroute
      usbutils
      usbimager
      ventoy
      xdotool
      xorg.xhost # add root to xsession: xhost si:localuser:root
      archivemount
      age
      air
      ansifilter
      autoreconfHook
      avrdude
      patchelf
      nix-index
      stable.awscli2
      blisp
      bun
      docker-buildx
      cargo
      cargo-wasi
      cheat
      clang-tools
      delve
      deno
      dive
      difftastic
      docker-compose
      eksctl
      exiv2
      ffmpeg
      file
      fluxcd
      ghc
      glow
      gnupg
      gnuplot
      go
      gotypist
      graphviz
      hottext
      speedread
      hexdino
      imagemagick
      jc
      joshuto
      jdk11
      k9s
      kaf
      kind
      kubectl
      kubectx
      kubernetes-helm
      kubetail
      lldb
      lsof
      (lua.withPackages (ps: with ps; [ luacheck ]))
      manga-tui
      massren
      mdbook
      mdl
      mysql80
      # musikcube
      # myPythonPackages.shirah-reader
      # myPythonPackages.adafruit-nrfutil
      # ngrok
      nix-init
      niv
      nodePackages.node2nix
      nodePackages.pnpm
      nodePackages.quicktype
      nodePackages.reveal-md
      nodePackages.typescript
      nodejs
      notify-desktop
      notify
      nushell
      openssl
      openvpn
      # openvpn_aws
      pandoc
      texlive.combined.scheme-medium
      typioca
      php
      # poetry
      postgresql
      (python3.withPackages (
        ps: with ps; [
          pyusb
          tkinter
        ]
      ))
      pwgen
      # python39Packages.grip
      # python39Packages.pip
      # python39Packages.pynvim
      # python39Packages.setuptools
      rclone
      redis
      renameutils
      # rustc
      # rustup
      sd
      # steel
      stern
      skopeo
      ssh-to-age
      tesseract4
      tio
      tldr
      # turbo
      ttyper
      # terminal-typeracer
      unrar
      wireshark-cli
      typespeed
      vegeta
      # visidata #broken
      wasmtime
      yarn
      yarn2nix
      yt-dlp
      yq
      # yubikey-manager #broken
      zgrviewer
      zoxide
    ];
  gui =
    with pkgs;
    extra
    ++ [
      # audacity
      google-chrome
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
      plex-mpv-shim
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
      telegram-desktop
      via
      vial
      vlc
      warpd
      wasistlos # whatsapp-for-linux
      dragon-drop
      yacreader
    ];
  gaming = with pkgs; [
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
    retroarchWithCores
    ryubing
    skyscraper
    (stable.emulationstation-de { retroarch = retroarchWithCores; })
    retool
    vulkan-tools
    wine
    # wine64
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
