{
  config,
  pkgs,
  lib,
  ...
}: {
  home.username = "kids";
  home.homeDirectory = "/home/kids";

  home.stateVersion = "23.05";

  programs.home-manager.enable = true;
}
