{pkgs, ...}: {
  home.packages = with pkgs; [
    cargo
    bat
    bc
    curl
    delta
    dig
    direnv
    entr
    # envy-sh
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
    # nixvim
    nmap
    p7zip
    ripgrep
    # ripgrep-all
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
    zip
    zoxide
    zsh
  ];
}
