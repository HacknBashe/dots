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

  homebrew = {
    enable = true;
    casks = [
      "todoist"
      "amethyst"
      "google-chrome"
      "affinity-designer"
      "affinity-photo"
      "affinity-publisher"
      "brave-browser"
      "libreoffice"
    ];
  };

  users.users.${user} = {
    name = "${user}";
    home = "/Users/${user}";
  };

  system.stateVersion = 5;
}
