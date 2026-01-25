{
  lib,
  pkgs,
  config,
  inputs,
  ...
}: {
  nix = {
    package = pkgs.nixVersions.stable;
    extraOptions = "experimental-features = nix-command flakes";
    registry.nixpkgs.flake = inputs.nixpkgs;
  };
  nixpkgs.config.allowUnfree = true;
  time.timeZone = lib.mkDefault "America/New_York";
}
