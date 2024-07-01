{
  description = "Nick's desktop flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl = {url = "github:nix-community/NixOS-WSL";};
  };

  outputs = {
    nixpkgs,
    home-manager,
    hyprland,
    nixos-wsl,
    ...
  } @ inputs: let
    # --- Settings ---- #
    wallLarge = /home/nick/Pictures/Walls/glowshroom-large.jpg;
    wallSmall = /home/nick/Pictures/Walls/glowshroom-small.jpg;
    # --- Settings ---- #

    colors = {
      background = "#1a1b26";
      foreground = "#c0caf5";
      cursor = "#c0caf5";
      text = "#1a1b26";
      default = {
        black = "#15161e";
        red = "#f7768e";
        green = "#9ece6a";
        yellow = "#e0af68";
        blue = "#7aa2f7";
        magenta = "#bb9af7";
        cyan = "#7dcfff";
        white = "#a9b1d6";
      };
      bright = {
        black = "#414868";
        red = "#f7768e";
        green = "#9ece6a";
        yellow = "#e0af68";
        blue = "#7aa2f7";
        magenta = "#bb9af7";
        cyan = "#7dcfff";
        white = "#c0caf5";
      };
      indexed = {
        one = "#ff9e64";
        two = "#db4b4b";
      };
    };
    system = "x86_64-linux";
  in {
    nixosConfigurations = {
      cla-wsl = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./modules/nix.nix
          ./hosts/cla-wsl/configuration.nix
          # ./modules/nixos/core.nix
          nixos-wsl.nixosModules.wsl
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.nick = {
              imports = [
                ./hosts/cla-wsl/home.nix
                ./modules/home-manager/terminal.nix
                ./modules/home-manager/development.nix
                ./modules/home-manager/neovim.nix
                ./modules/home-manager/tmux.nix
                ./modules/home-manager/btop.nix
              ];
            };
            home-manager.extraSpecialArgs = {inherit inputs colors;};
          }
        ];
        specialArgs = {inherit inputs nixos-wsl;};
      };

      meraxes-wsl = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./modules/nix.nix
          ./hosts/meraxes-wsl/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.nick = import ./hosts/meraxes-wsl/home.nix;
          }
        ];
        specialArgs = {inherit nixos-wsl;};
      };

      meraxes = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./modules/nix.nix
          ./hosts/meraxes/configuration.nix
          ./modules/nixos/core.nix
          ./modules/nixos/hyprland.nix
          ./modules/nixos/desktop.nix
          ./modules/nixos/development.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.nick = {
              imports = [
                ./hosts/meraxes/home.nix
                ./modules/home-manager/neovim.nix
                ./modules/home-manager/hyprland.nix
                ./modules/home-manager/btop.nix
              ];
            };
            home-manager.extraSpecialArgs = {inherit colors wallLarge wallSmall;};
          }
        ];
        specialArgs = {inherit inputs colors wallLarge wallSmall;};
      };
    };

    homeConfigurations = {
      nick = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-darwin;
        modules = [
          ./modules/nix.nix
          ./hosts/toothless/home.nix
          ./modules/home-manager/neovim.nix
          ./modules/home-manager/tmux.nix
          ./modules/home-manager/btop.nix
        ];
        extraSpecialArgs = {inherit inputs colors;};
      };

      hack56224 = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        modules = [
          ./modules/nix.nix
          ./hosts/cla-vm/home.nix
          ./modules/home-manager/terminal.nix
          ./modules/home-manager/development.nix
          ./modules/home-manager/neovim.nix
          ./modules/home-manager/tmux.nix
          ./modules/home-manager/btop.nix
        ];
        extraSpecialArgs = {inherit inputs colors;};
      };
    };
  };
}
