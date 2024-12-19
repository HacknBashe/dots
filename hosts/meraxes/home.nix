{
  config,
  pkgs,
  lib,
  ...
}: {
  home.username = "nick";
  home.homeDirectory = "/home/nick";
  homeDirPath = "/home/nick/";

  home.stateVersion = "23.05";

  programs.home-manager.enable = true;

  home.file = {
    ".gitconfig.local" = {
      text = ''
        [user]
        name = Nick Hackford
        email = nick.hackford@gmail.com
      '';
      target = ".gitconfig.local";
    };

    "cava" = {
      text = ''
        [color]
        gradient = 1
        gradient_count = 7
        gradient_color_1 = '${config.theme.colors.default.magenta}'
        gradient_color_2 = '${config.theme.colors.default.blue}'
        gradient_color_3 = '${config.theme.colors.default.cyan}'
        gradient_color_4 = '${config.theme.colors.default.green}'
        gradient_color_5 = '${config.theme.colors.default.yellow}'
        gradient_color_6 = '${config.theme.colors.indexed.one}'
        gradient_color_7 = '${config.theme.colors.indexed.two}'
      '';
      target = ".config/cava/config";
    };
  };
}
