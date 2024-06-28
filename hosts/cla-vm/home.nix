{
  config,
  pkgs,
  lib,
  ...
}: {
  home.username = "hack56224";
  home.homeDirectory = "/home/hack56224";

  home.stateVersion = "23.11"; # Please read the comment before changing.

  programs.home-manager.enable = true;
}
