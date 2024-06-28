{
  description = "Nick's desktop flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl = {url = "github:nix-community/NixOS-WSL";};
  };

  outputs = {
    nixpkgs,
    home-manager,
    hyprland,
    stylix,
    nixos-wsl,
    ...
  } @ inputs: let
    # --- Settings ---- #
    wallLarge = /home/nick/Pictures/Walls/glowshroom-large.jpg;
    wallSmall = /home/nick/Pictures/Walls/glowshroom-small.jpg;
    # --- Settings ---- #

    system = "x86_64-linux";
  in {
    nixosConfigurations = {
      cla-wsl = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./modules/nix.nix
          ./hosts/cla-wsl/configuration.nix
          stylix.nixosModules.stylix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.nick = {
              imports = [
                ./hosts/cla-wsl/home.nix
                ./modules/home-manager/neovim.nix
                ./modules/home-manager/btop.nix
              ];
            };
          }
        ];
        specialArgs = {inherit inputs nixos-wsl;};
      };

      meraxes-wsl = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./modules/nix.nix
          ./hosts/meraxes-wsl/configuration.nix
          stylix.nixosModules.stylix
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
          stylix.nixosModules.stylix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.nick = import ./hosts/meraxes/home.nix;
            home-manager.extraSpecialArgs = {inherit wallLarge wallSmall;};
          }
        ];
        specialArgs = {inherit wallLarge wallSmall hyprland;};
      };
    };

    homeConfigurations = {
      nick = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        modules = [
          ./hosts/toothless/home.nix
        ];
        extraSpecialArgs = {inherit nixpkgs system;};
      };

      hack56224 = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        modules = [stylix.homeManagerModules.stylix ./hosts/cla-vm/home.nix];
        extraSpecialArgs = {inherit nixpkgs system;};
      };
    };
  };
}
