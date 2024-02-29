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
  };

  outputs = { nixpkgs, home-manager, hyprland, stylix, ... }:
    let
      # --- Settings ---- #
      wallLarge = /home/nick/Pictures/Walls/glowshroom-large.jpg;
      wallSmall = /home/nick/Pictures/Walls/glowshroom-small.jpg;
      # --- Settings ---- #

      system = "x86_64-linux";
      commonConfig = { lib, pkgs, config, ... }: {
        nix = {
          package = pkgs.nixFlakes;
          extraOptions = "experimental-features = nix-command flakes";
          registry.nixpkgs.flake = nixpkgs;
        };
        nixpkgs.config.allowUnfree = true;
      };
    in {
      nixosConfigurations = {
        meraxes = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            commonConfig
            ./hosts/meraxes/configuration.nix
            stylix.nixosModules.stylix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.nick = import ./hosts/meraxes/home.nix;
              home-manager.extraSpecialArgs = { inherit wallLarge wallSmall; };
            }
          ];
          specialArgs = { inherit wallLarge wallSmall; };
        };
      };
    };
}
