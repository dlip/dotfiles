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
    nix-darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
    mac-app-util.url = "github:hraban/mac-app-util";
    vimplugin-telescope-gitsigns = {
      url = "github:radyz/telescope-gitsigns";
      flake = false;
    };
    vimplugin-one-small-step-for-vimkind = {
      url = "github:jbyuki/one-small-step-for-vimkind";
      flake = false;
    };
    vimplugin-nu = {
      url = "github:LhKipp/nvim-nu";
      flake = false;
    };
    repo-nnn = {
      url = "github:jarun/nnn";
      flake = false;
    };
    repo-tmux-catppuccin = {
      url = "github:catppuccin/tmux";
      flake = false;
    };
    repo-catppuccin-zsh-syntax-highlighting = {
      url = "github:catppuccin/zsh-syntax-highlighting";
      flake = false;
    };
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
      home-manager,
      flake-utils,
      nix-on-droid,
      sops-nix,
      nix-darwin,
      ...
    }:
    let
      pkgsForSystem =
        {
          system,
          pkgs ? nixpkgs,
          overlays ? (import ./nix/overlays inputs),
        }:
        import pkgs {
          inherit system;
          config.allowUnfree = true;
          config.permittedInsecurePackages = [
            # opentabletdriver
            "dotnet-runtime-6.0.36"
            "dotnet-sdk-wrapped-6.0.428"
            "dotnet-sdk-6.0.428"
            "libsoup-2.74.3"
            "freeimage-3.18.0-unstable-2024-04-18"
            "ventoy-1.1.07"
          ];
          overlays = overlays ++ [
            (final: prev: {
              stable = pkgsForSystem {
                inherit system;
                pkgs = nixpkgs-stable;
                overlays = (import ./nix/overlays/stable.nix inputs);
              };
            })
          ];
        };

      configs = {
        dane = [
          ./nix/home
          {
            home = {
              username = "dane";
              homeDirectory = "/home/dane";
            };
          }
        ];
        docker = [
          ./nix/home/default.nix
          ./nix/home/desktop.nix
          {
            home = {
              username = "root";
              homeDirectory = "/root";
            };
          }
        ];
      };
    in
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = pkgsForSystem { inherit system; };

        createHomeConfiguration =
          name: config:
          flake-utils.lib.mkApp {
            drv =
              (home-manager.lib.homeManagerConfiguration {
                inherit pkgs;
                modules = config;
              }).activationPackage;
          };
      in
      rec {
        inherit pkgs;
        defaultApp = apps.repl;
        apps = {
          repl = flake-utils.lib.mkApp {
            drv = pkgs.writeShellScriptBin "repl" ''
              confnix=$(mktemp)
              echo "builtins.getFlake (toString $(git rev-parse --show-toplevel))" >$confnix
              trap "rm $confnix" EXIT
              nix repl $confnix
            '';
          };
          homeConfigurations = builtins.mapAttrs createHomeConfiguration configs;
        };
        packages = with pkgs; {
          inherit actualServer;

          pushNixStoreDockerImage = pkgs.callPackage ./nix/pkgs/pushNixStoreDockerImage { };
        };
        devShell = pkgs.mkShell {
          buildInputs = [
            pkgs.nixvim
          ];
        };
      }
    )
    // {
      nixosConfigurations = {
        dex = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          pkgs = pkgsForSystem { system = "x86_64-linux"; };
          modules = [
            ./nix/systems/dex/configuration.nix
            ./nix/modules/linux-desktop.nix
            ./nix/modules/linux-graphical.nix
            ./nix/modules/gaming.nix
            sops-nix.nixosModules.default
          ];
        };
        x = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          pkgs = pkgsForSystem { system = "x86_64-linux"; };
          modules = [
            ./nix/systems/x/configuration.nix
            ./nix/modules/linux-desktop.nix
            ./nix/modules/linux-graphical.nix
            ./nix/modules/gaming.nix
            sops-nix.nixosModules.default
          ];
        };
        ptv = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          pkgs = pkgsForSystem { system = "x86_64-linux"; };
          modules = [
            ./nix/systems/ptv/configuration.nix
            home-manager.nixosModules.home-manager
            sops-nix.nixosModules.default
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users = {
                  tv = {
                    home.name = "TV Lipscombe";
                    home.email = "tv@lipscombe.com.au";
                    imports = [
                      ./nix/home/default.nix
                    ];
                  };
                };
              };
            }
          ];
        };
      };
      # nix-on-droid switch --flake .#default
      nixOnDroidConfigurations.default = nix-on-droid.lib.nixOnDroidConfiguration {
        modules = [
          ./nix/systems/nix-on-droid/configuration.nix
          {
            # Configure home-manager
            home-manager = {
              config = ./nix/home/nix-on-droid.nix;
              backupFileExtension = "hm-bak";
              useGlobalPkgs = true;
            };
          }
        ];
        pkgs = pkgsForSystem { system = "aarch64-linux"; };
        home-manager-path = home-manager.outPath;
      };
      # nix run nix-darwin -- switch --flake .#default
      darwinConfigurations.default = nix-darwin.lib.darwinSystem {
        modules = [
          ./nix/systems/darwin/configuration.nix
          home-manager.darwinModules.default
          {
            users.users.dane.home = "/Users/dane";
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "backup";
              users = {
                dane = {
                  home = {
                    email = "danelipscombe@gmail.com";
                  };
                  imports = [
                    ./nix/home/macos.nix
                  ];
                };
              };
            };
          }
        ];
        specialArgs = {
          pkgs = pkgsForSystem { system = "aarch64-darwin"; };
        };
      };
    };
}
