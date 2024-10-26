{
  config,
  pkgs,
  lib,
  ...
}: {
  programs = {
    alacritty = {
      enable = true;
      settings = {
        font.size = 20.0;
        font.bold.style = lib.mkForce "Regular";
        font.normal.family = config.theme.fontMono;
        font.normal.style = lib.mkForce "ExtraLight";
        window = {
          decorations = "none";
          dynamic_padding = true;
          opacity = lib.mkForce 0.9;
        };
        colors = {
          primary = {
            background = config.theme.colors.background;
            foreground = config.theme.colors.foreground;
          };
          cursor = {
            text = config.theme.colors.text;
            cursor = config.theme.colors.cursor;
          };
          normal = config.theme.colors.default;
          bright = config.theme.colors.bright;
          dim = config.theme.colors.default;
          indexed_colors = [
            {
              index = 16;
              color = config.theme.colors.indexed.one;
            }
            {
              index = 17;
              color = config.theme.colors.indexed.two;
            }
          ];
        };
      };
    };
  };
}
