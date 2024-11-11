{pkgs, ...}: {
  home.username = "nick";
  home.homeDirectory = "/home/nick";

  home.stateVersion = "23.05";

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    azure-cli
    bc
  ];
}
