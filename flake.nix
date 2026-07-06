{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hermes-agent.url = "github:NousResearch/hermes-agent/v2026.7.1";
    storyteller.url = "git+https://gitlab.com/dlip/storyteller?ref=dlip";
    # nix-darwin = {
    #   url = "github:LnL7/nix-darwin/master";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    # hyprland = {
    #   url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    # hyprcursor-catppuccin = {
    #   url = "github:NotAShelf/hyprcursor-catppuccin";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    nix-on-droid = {
      url = "github:nix-community/nix-on-droid/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    # actual-server = {
    #   url = "github:actualbudget/actual-server";
    #   flake = false;
    # };
    emoji-menu = {
      url = "github:jchook/emoji-menu";
      flake = false;
    };
    # dgop = {
    #   url = "github:AvengeMedia/dgop";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    dms = {
      url = "github:AvengeMedia/DankMaterialShell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia/cachix";
    };
    mokuro-reader = {
      url = "github:dlip/mokuro-reader";
    };
    power-menu = {
      url = "github:jluttine/rofi-power-menu";
      flake = false;
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # helix = {
    #   url = "github:mattwparas/helix/steel-event-system";
    # };
    # vimplugin-telescope-gitsigns = {
    #   url = "github:radyz/telescope-gitsigns";
    #   flake = false;
    # };
    # vimplugin-one-small-step-for-vimkind = {
    #   url = "github:jbyuki/one-small-step-for-vimkind";
    #   flake = false;
    # };
    # vimplugin-nu = {
    #   url = "github:LhKipp/nvim-nu";
    #   flake = false;
    # };
    # repo-nnn = {
    #   url = "github:jarun/nnn";
    #   flake = false;
    # };
    # repo-tmux-catppuccin = {
    #   url = "github:catppuccin/tmux";
    #   flake = false;
    # };
    # repo-catppuccin-zsh-syntax-highlighting = {
    #   url = "github:catppuccin/zsh-syntax-highlighting";
    #   flake = false;
    # };
    # nixvim = {
    #   url = "github:nix-community/nixvim";
    #   # If you are not running an unstable channel of nixpkgs, select the corresponding branch of nixvim.
    #   # url = "github:nix-community/nixvim/nixos-23.05";
    #
    #   # inputs.nixpkgs.follows = "nixpkgs";
    # };
    # talon = {
    #   url = "github:nix-community/talon-nix";
    # };
    nixgl.url = "github:nix-community/nixGL";
    tududi.url = "github:dlip/tududi/feature/nixos-module";
    sparkyfitness.url = "github:dlip/SparkyFitness/nix-module";
  };

  outputs =
    inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./nix/modules);

  nixConfig = {
    extra-substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://nixpkgs-wayland.cachix.org"
      "https://cache.nixos-cuda.org"
      "https://noctalia.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
      "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    ];
  };
}
