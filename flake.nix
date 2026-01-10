{
  description = "Nick's desktop flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgsold.url = "github:nixos/nixpkgs?ref=nixos-25.11";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ghostty = {
      url = "git+ssh://git@github.com/ghostty-org/ghostty";
    };

    hyprland = {
      url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprlock = {
      url = "git+https://github.com/hyprwm/hyprlock";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    caelestia-shell = {
      url = "github:caelestia-dots/shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-yazi-plugins = {
      url = "github:lordkekz/nix-yazi-plugins";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    # For Steam
    extest = {
      url = "github:chaorace/extest-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    wivrn = {
      url = "github:WiVRn/WiVRn/v25.12";  # Pin to v25.12 release to match headset version
      inputs.nixpkgs.follows = "nixpkgs";
    };

    opencode = {
      url = "github:anomalyco/opencode";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    nixpkgsold,
    home-manager,
    sops-nix,
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
          ./modules/nixos/fish.nix
          ./modules/nixos/sddm.nix
          ./modules/nixos/hyprland.nix
          ./modules/nixos/desktop.nix
          ./modules/nixos/gamedev.nix
          ./modules/nixos/steam.nix
          ./modules/nixos/vms.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.sharedModules = [
              sops-nix.homeManagerModules.sops
            ];
            home-manager.users = {
              nick = {
                imports = [
                  ./hosts/meraxes/home.nix
                  ./modules/theme.nix
                  ./modules/home-manager/shell.nix
                  ./modules/home-manager/sops.nix
                  ./modules/home-manager/development.nix
                  ./modules/home-manager/vms.nix
                  ./modules/home-manager/neovim-lazy.nix
                  ./modules/home-manager/tmux.nix
                  ./modules/home-manager/zellij.nix
                  ./modules/home-manager/btop.nix
                  ./modules/home-manager/hyprland.nix
                  ./modules/home-manager/quickshell.nix
                  ./modules/home-manager/ghostty.nix
                  ./modules/home-manager/alacritty.nix
                  ./modules/home-manager/opencode.nix
                  ./modules/home-manager/gtk.nix
                  ./modules/home-manager/qt.nix
                  ./modules/home-manager/steam.nix
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
          ./modules/nixos/caddy.nix
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
                  ./modules/home-manager/neovim-lazy.nix
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
      nightmare = nixpkgs.lib.nixosSystem {
        system = systemLinux;
        modules = [
          ./modules/nix.nix
          ./hosts/nightmare/configuration.nix
          inputs.nixos-hardware.nixosModules.microsoft-surface-pro-intel
          {
            services.iptsd.enable = true;
          }
          ./modules/nixos/shell.nix
          ./modules/nixos/phosh.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users = {
              nick = {
                imports = [
                  ./hosts/nightmare/home.nix
                  ./modules/theme.nix
                  ./modules/home-manager/shell.nix
                  ./modules/home-manager/development.nix
                  ./modules/home-manager/neovim-lazy.nix
                  ./modules/home-manager/tmux.nix
                  ./modules/home-manager/btop.nix
                  ./modules/home-manager/opencode.nix
                ];
              };
              kids = {
                imports = [
                  ./hosts/nightmare/kids.nix
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
                ./modules/theme.nix
                ./hosts/toothless/home.nix
                ./modules/home-manager/shell.nix
                ./modules/home-manager/development.nix
                ./modules/home-manager/neovim-lazy.nix
                ./modules/home-manager/tmux.nix
                ./modules/home-manager/btop.nix
                ./modules/home-manager/ghostty.nix
                ./modules/home-manager/aerospace.nix
                ./modules/home-manager/opencode.nix
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
          # ./modules/darwin/karabiner.nix
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
                ./modules/home-manager/neovim-lazy.nix
                ./modules/home-manager/tmux.nix
                ./modules/home-manager/btop.nix
                ./modules/home-manager/ghostty.nix
                ./modules/home-manager/aerospace.nix
                ./modules/home-manager/opencode.nix
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
