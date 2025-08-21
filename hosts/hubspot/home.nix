{
  config,
  pkgs,
  lib,
  ...
}: {
  isHubspot = true;
  home.homeDirectory = "/Users/nhackford";

  home = {
    stateVersion = "24.05"; # Please read the comment before changing.
    sessionVariables = {NIX_SHELL_PRESERVE_PROMPT = 1;};
  };

  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    nerd-fonts.sauce-code-pro
    font-awesome
    raleway

    spotify
  ];

  programs = {
    home-manager.enable = true;
  };

  home.file = {
    ".hammerspoon" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/dots/files/config/hammerspoon";
      target = ".hammerspoon";
      recursive = true;
    };
  };
}
