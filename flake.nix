{
  description = "Nick's desktop flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgsold.url = "github:nixos/nixpkgs?ref=nixos-24.05";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl = {url = "github:nix-community/NixOS-WSL";};

    ghostty = {
      url = "git+ssh://git@github.com/ghostty-org/ghostty";
      inputs.nixpkgs-stable.follows = "nixpkgs";
      inputs.nixpkgs-unstable.follows = "nixpkgs";
    };

    hyprland = {
      url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprlock = {
      url = "git+https://github.com/hyprwm/hyprlock";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ags = {
      url = "git+https://github.com/Aylur/ags";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-yazi-plugins = {
      url = "github:nickhackford/nix-yazi-plugins";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # For Steam
    extest.url = "github:chaorace/extest-nix";
  };

  outputs = {
    nixpkgs,
    nixpkgsold,
    home-manager,
    nixos-wsl,
    ...
  } @ inputs: let
    systemLinux = "x86_64-linux";
    systemDarwin = "aarch64-darwin";
  in {
    nixosConfigurations = {
      meraxes = nixpkgs.lib.nixosSystem {
        system = systemLinux;
        modules = [
          ./modules/nix.nix
          ./modules/theme.nix
          ./hosts/meraxes/configuration.nix
          ./modules/nixos/shell.nix
          ./modules/nixos/sddm.nix
          ./modules/nixos/hyprland.nix
          ./modules/nixos/desktop.nix
          ./modules/nixos/vms.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users = {
              nick = {
                imports = [
                  ./hosts/meraxes/home.nix
                  ./modules/theme.nix
                  ./modules/home-manager/shell.nix
                  ./modules/home-manager/development.nix
                  ./modules/home-manager/vms.nix
                  ./modules/home-manager/neovim.nix
                  ./modules/home-manager/tmux.nix
                  ./modules/home-manager/zellij.nix
                  ./modules/home-manager/btop.nix
                  ./modules/home-manager/hyprland.nix
                  ./modules/home-manager/ags.nix
                  ./modules/home-manager/ghostty.nix
                  ./modules/home-manager/alacritty.nix
                  ./modules/home-manager/gtk.nix
                  ./modules/home-manager/qt.nix
                ];
              };
              kids = {
                imports = [
                  ./hosts/meraxes/kids.nix
                ];
              };
            };
            home-manager.extraSpecialArgs = {inherit inputs;};
          }
        ];
        specialArgs = {inherit inputs;};
      };
      sindragosa = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          ./modules/nix.nix
          ./modules/theme.nix
          ./hosts/sindragosa/configuration.nix
          ./modules/nixos/shell.nix
          ./modules/nixos/jellyfin.nix
          ./modules/nixos/adguard.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users = {
              nick = {
                imports = [
                  ./hosts/mushu/home.nix
                  ./modules/theme.nix
                  ./modules/home-manager/shell.nix
                  ./modules/home-manager/neovim.nix
                  ./modules/home-manager/tmux.nix
                  ./modules/home-manager/btop.nix
                ];
              };
            };
            home-manager.extraSpecialArgs = {inherit inputs;};
          }
        ];
        specialArgs = {inherit inputs;};
      };
      mushu = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          ./modules/nix.nix
          ./modules/theme.nix
          ./hosts/mushu/configuration.nix
          ./modules/nixos/shell.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users = {
              nick = {
                imports = [
                  ./hosts/mushu/home.nix
                  ./modules/theme.nix
                  ./modules/home-manager/shell.nix
                  ./modules/home-manager/neovim.nix
                  ./modules/home-manager/tmux.nix
                  ./modules/home-manager/btop.nix
                ];
              };
            };
            home-manager.extraSpecialArgs = {inherit inputs;};
          }
        ];
        specialArgs = {inherit inputs;};
      };
    };

    darwinConfigurations = {
      toothless = inputs.darwin.lib.darwinSystem {
        modules = [
          ./hosts/toothless/configuration.nix
          ./modules/theme.nix
          ./modules/darwin/aerospace.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.nick = {
              imports = [
                ./hosts/toothless/home.nix
                ./modules/theme.nix
                ./modules/home-manager/shell.nix
                ./modules/home-manager/development.nix
                ./modules/home-manager/neovim.nix
                ./modules/home-manager/tmux.nix
                ./modules/home-manager/btop.nix
                ./modules/home-manager/ghostty.nix
                ./modules/home-manager/aerospace.nix
                ./modules/home-manager/alacritty.nix
              ];
            };
            home-manager.extraSpecialArgs = {inherit inputs;};
          }
        ];
        specialArgs = {inherit inputs;};
      };

      JGR2T596J9 = inputs.darwin.lib.darwinSystem {
        modules = [
          ./hosts/hubspot/configuration.nix
          ./modules/theme.nix
          ./modules/darwin/aerospace.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.nhackford = {
              imports = [
                ./modules/theme.nix
                ./hosts/hubspot/home.nix
                ./modules/home-manager/shell.nix
                ./modules/home-manager/development.nix
                ./modules/home-manager/neovim.nix
                ./modules/home-manager/tmux.nix
                ./modules/home-manager/btop.nix
                ./modules/home-manager/ghostty.nix
                ./modules/home-manager/aerospace.nix
              ];
            };
            home-manager.extraSpecialArgs = {inherit inputs;};
          }
        ];
        specialArgs = {inherit inputs;};
      };
    };

    homeConfigurations = {
      nick = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${systemDarwin};
        modules = [
          ./modules/nix.nix
          ./modules/theme.nix
          ./hosts/toothless/home.nix
          ./modules/home-manager/shell.nix
          ./modules/home-manager/development.nix
          ./modules/home-manager/neovim.nix
          ./modules/home-manager/tmux.nix
          ./modules/home-manager/btop.nix
          ./modules/home-manager/alacritty.nix
        ];
        extraSpecialArgs = {inherit inputs;};
      };
    };
  };
}
