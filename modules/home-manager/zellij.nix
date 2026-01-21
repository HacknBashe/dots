{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [zellij];

  home.file = {
    "zellij" = {
      target = ".config/zellij/config.kdl";
      text = ''
        themes {
            default {
                fg "${config.theme.colors.foreground}"
                bg "${config.theme.colors.background}"
                black "${config.theme.colors.default.black}"
                red "${config.theme.colors.default.red}"
                green "${config.theme.colors.default.green}"
                yellow "${config.theme.colors.default.yellow}"
                blue "${config.theme.colors.default.blue}"
                magenta "${config.theme.colors.default.magenta}"
                cyan "${config.theme.colors.default.cyan}"
                white "${config.theme.colors.default.white}"
                orange "${config.theme.colors.indexed.orange}"
            }
        }
      '';
    };
  };
}
