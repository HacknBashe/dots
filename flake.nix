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

    wezterm = {
      url = "github:wez/wezterm?dir=nix";
    };

    hyprland = {
      url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprlock = {
      url = "git+https://github.com/hyprwm/hyprlock";
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
                ./modules/home-manager/shell.nix
                ./modules/home-manager/development.nix
                ./modules/home-manager/neovim.nix
                ./modules/home-manager/tmux.nix
                ./modules/home-manager/zellij.nix
                ./modules/home-manager/btop.nix
                ./modules/home-manager/hyprland.nix
                ./modules/home-manager/ghostty.nix
                ./modules/home-manager/alacritty.nix
                ./modules/home-manager/wezterm.nix
                ./modules/home-manager/gtk.nix
                ./modules/home-manager/qt.nix
              ];
            };
            home-manager.extraSpecialArgs = {inherit inputs;};
          }
        ];
        specialArgs = {inherit inputs;};
      };
    };

    darwinConfigurations = {
      toothless = inputs.darwin.lib.darwinSystem {
        system = "x86_64-darwin";
        modules = [
          ./hosts/toothless/configuration.nix
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
                ./modules/home-manager/neovim.nix
                ./modules/home-manager/tmux.nix
                ./modules/home-manager/btop.nix
                ./modules/home-manager/alacritty.nix
                ./modules/home-manager/wezterm.nix
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
          ./modules/home-manager/wezterm.nix
        ];
        extraSpecialArgs = {inherit inputs;};
      };
    };
  };
}
