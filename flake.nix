{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
    niri-flake = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
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
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
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
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nixpkgs-stable,
      flake-utils,
      nix-on-droid,
      sops-nix,
      nix-darwin,
      dms,
      home-manager,
      ...
    }:
    let
      pkgsForSystem =
        {
          system,
        }:
        import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            permittedInsecurePackages = [
              # opentabletdriver
              "dotnet-runtime-6.0.36"
              "dotnet-sdk-wrapped-6.0.428"
              "dotnet-sdk-6.0.428"
              "libsoup-2.74.3"
              "ventoy-1.1.07"
            ];
          };
          overlays = (import ./nix/pkgs inputs) ++ [
            (final: prev: {
              stable = import nixpkgs-stable {
                inherit system;
                config = {
                  allowUnfree = true;
                  permittedInsecurePackages = [
                    "freeimage-3.18.0-unstable-2024-04-18"
                  ];
                };
                overlays = (import ./nix/pkgs/stable.nix inputs);
              };
              cudaPkgs = import nixpkgs {
                inherit system;
                config = {
                  allowUnfree = true;
                  cudaSupport = true;
                };
              };
            })
          ];
        };
    in
    (flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = pkgsForSystem { inherit system; };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = pkgs.groups.default;
        };
      }
    ))
    // {
      nixosConfigurations = {
        dex = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          pkgs = pkgsForSystem { system = "x86_64-linux"; };
          modules = [
            ./nix/systems/dex/configuration.nix
            sops-nix.nixosModules.default
            dms.nixosModules.dank-material-shell
            dms.nixosModules.greeter
          ];
        };
        x = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          pkgs = pkgsForSystem { system = "x86_64-linux"; };
          specialArgs = { inherit inputs; };
          modules = [
            ./nix/systems/x/configuration.nix
            sops-nix.nixosModules.default
            dms.nixosModules.dank-material-shell
            dms.nixosModules.greeter
          ];
        };
        ptv = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          pkgs = pkgsForSystem { system = "x86_64-linux"; };
          modules = [
            ./nix/systems/ptv/configuration.nix
            sops-nix.nixosModules.default
          ];
        };
      };
      # nix run home-manager/master -- switch --flake .#docker
      homeConfigurations = {
        docker = home-manager.lib.homeManagerConfiguration {
          pkgs = pkgsForSystem { system = "x86_64-linux"; };
          modules = [ ./nix/home/docker.nix ];
        };
        docker-arm = home-manager.lib.homeManagerConfiguration {
          pkgs = pkgsForSystem { system = "aarch64-linux"; };
          modules = [ ./nix/home/docker.nix ];
        };
      };
      # nix-on-droid switch --flake .#default
      nixOnDroidConfigurations.default = nix-on-droid.lib.nixOnDroidConfiguration {
        pkgs = pkgsForSystem { system = "aarch64-linux"; };
        modules = [ ./nix/systems/nix-on-droid/configuration.nix ];
      };
    };
}
