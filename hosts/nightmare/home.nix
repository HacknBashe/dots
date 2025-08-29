{pkgs, ...}: {
  home.username = "nick";
  home.homeDirectory = "/home/nick";
  home.stateVersion = "25.05";

  home.packages = with pkgs; [
    git
    ghostty
    firefox
  ];
}
