{
  config,
  pkgs,
  lib,
  ...
}: {
  home.username = "nick";
  home.homeDirectory = "/home/nick";

  home.stateVersion = "23.05";

  programs.home-manager.enable = true;
  # TODO: organize shell/dev modules. Probably combine them and add options
  # config.development.guitools
  home.packages = with pkgs; [
    git
    entr
    lazygit

    alejandra
    nixd
    shfmt

    lua
    lua-language-server
    stylua

    nodejs_22
    nodePackages.typescript-language-server
  ];

  home.file = {
    ".gitconfig" = {
      source = ../../files/gitconfig;
      target = ".gitconfig";
    };
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
