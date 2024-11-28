{
  pkgs,
  inputs,
  ...
}: let
  user = "nick";
in {
  services.nix-daemon.enable = true;
  nixpkgs = {
    hostPlatform = "aarch64-darwin";
    config.allowUnfree = true;
  };
  nix.settings.experimental-features = "nix-command flakes";

  programs.zsh.enable = true;

  # homebrew = {
  #   enable = true;
  #   brews = [
  #     "FelixKratz/formulae/borders"
  #     "FelixKratz/formulae/sketchybar"
  #     "switchaudio-osx"
  #     "ical-buddy"
  #   ];
  #   casks = [
  #     "todoist"
  #     "google-chrome"
  #     "affinity-designer"
  #     "affinity-photo"
  #     "affinity-publisher"
  #     "brave-browser"
  #     "libreoffice"
  #     "nikitabobko/tap/aerospace"
  #     "karabiner-elements"
  #     "visual-studio-code"
  #   ];
  # };

  users.users.${user} = {
    name = "${user}";
    home = "/Users/${user}";
  };

  system.stateVersion = 5;
}
