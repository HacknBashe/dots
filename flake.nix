{
  description = "Nick's desktop flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgsold.url = "github:nixos/nixpkgs?ref=nixos-24.05";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprlock = {
      url = "git+https://github.com/hyprwm/hyprlock";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl = {url = "github:nix-community/NixOS-WSL";};

    extest.url = "github:chaorace/extest-nix";

    wezterm = {
      url = "github:wez/wezterm?dir=nix";
    };
  };

  outputs = {
    nixpkgs,
    nixpkgsold,
    home-manager,
    hyprland,
    nixos-wsl,
    ...
  } @ inputs: let
    system = "x86_64-linux";
  in {
    nixosConfigurations = {
      meraxes = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./modules/nix.nix
          ./modules/theme.nix
          ./hosts/meraxes/configuration.nix
          ./modules/nixos/core.nix
          ./modules/nixos/hyprland.nix
          ./modules/nixos/desktop.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.nick = {
              imports = [
                ./hosts/meraxes/home.nix
                ./modules/theme.nix
                ./modules/home-manager/development.nix
                ./modules/home-manager/neovim.nix
                ./modules/home-manager/tmux.nix
                ./modules/home-manager/btop.nix
                ./modules/home-manager/hyprland.nix
                ./modules/home-manager/gtk.nix
              ];
            };
            home-manager.extraSpecialArgs = {inherit inputs;};
          }
        ];
        specialArgs = {inherit inputs;};
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

      cla-wsl = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./modules/nix.nix
          ./hosts/cla-wsl/configuration.nix
          ./modules/theme.nix
          # ./modules/nixos/core.nix
          nixos-wsl.nixosModules.wsl
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.nick = {
              imports = [
                ./hosts/cla-wsl/home.nix
                ./modules/theme.nix
                ./modules/home-manager/terminal.nix
                ./modules/home-manager/development.nix
                ./modules/home-manager/neovim.nix
                ./modules/home-manager/tmux.nix
                ./modules/home-manager/btop.nix
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
        pkgs = nixpkgs.legacyPackages.aarch64-darwin;
        modules = [
          ./modules/nix.nix
          ./hosts/toothless/home.nix
          ./modules/home-manager/terminal.nix
          ./modules/home-manager/development.nix
          ./modules/home-manager/neovim.nix
          ./modules/home-manager/tmux.nix
          ./modules/home-manager/btop.nix
        ];
        extraSpecialArgs = {inherit inputs;};
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
        extraSpecialArgs = {inherit inputs;};
      };
    };
  };
}
