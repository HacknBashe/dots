{...}: let
  user = "nick";
in {
  nixpkgs = {
    hostPlatform = "aarch64-darwin";
    config.allowUnfree = true;
  };
  nix.settings.experimental-features = "nix-command flakes";

  programs.zsh.enable = true;

  # homebrew = {
  #   enable = true;
  #   brews = [
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
