{
  config,
  pkgs,
  lib,
  ...
}: {
  home.username = "nick";
  home.homeDirectory = "/home/nick";

  home.stateVersion = "24.11";

  programs.home-manager.enable = true;

  development.enableRust = false;
  development.enablePython = false;
  development.enableJava = false;
}
