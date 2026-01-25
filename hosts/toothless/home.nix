{
  config,
  pkgs,
  lib,
  ...
}: {
  home.homeDirectory = "/Users/nick";

  home = {
    stateVersion = "23.11"; # Please read the comment before changing.
    sessionVariables = {NIX_SHELL_PRESERVE_PROMPT = 1;};
  };

  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    nerd-fonts.sauce-code-pro
    font-awesome
    raleway

    discord
    spotify
  ];

  programs = {
    home-manager.enable = true;
  };

  home.file = {
    ".gitconfig.local" = {
      text = ''
        [user]
        name = Nick Hackford
        email = nick.hackford@gmail.com
      '';
      target = ".gitconfig.local";
    };
  };

}
