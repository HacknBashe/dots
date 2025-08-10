{
  pkgs,
  lib,
  ...
}: {
  programs.fish.enable = true;
  environment.shells = with pkgs; [fish zsh];
}
