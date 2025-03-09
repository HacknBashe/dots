{
  pkgs,
  config,
  inputs,
  ...
}: let
  linuxGhostty =
    if pkgs.stdenv.isLinux
    then [
      inputs.ghostty.packages.x86_64-linux.default
    ]
    else [];
  colors = config.theme.colors;
in {
  home.packages =
    linuxGhostty;

  home.file = {
    ".config/ghostty/config" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}.config/dots/files/config/ghostty/config";
      target = ".config/ghostty/config";
    };
    ".config/ghostty/theme" = {
      text = ''
        background = ${colors.background}
        foreground= ${colors.foreground}

        font-size = 24
        font-family = ${config.theme.fontMono}
        font-style = light

        font-family-bold = ${config.theme.fontMono}
        font-style-bold = semibold

        font-family-italic = ${config.theme.fontMono}
        font-style-italic = light italic

        font-family-bold-italic = ${config.theme.fontMono}
        font-style-bold-italic = semibold italic

        background-opacity = .8
        # black
        palette = 0=${colors.default.black}
        palette = 8=${colors.bright.black}
        # red
        palette = 1=${colors.bright.red}
        palette = 9=${colors.bright.red}
        # green
        palette = 2=${colors.default.green}
        palette = 10=${colors.default.green}
        # yellow
        palette = 3=${colors.default.yellow}
        palette = 11=${colors.default.yellow}
        # blue
        palette = 4=${colors.default.blue}
        palette = 12=${colors.default.blue}
        # magenta
        palette = 5=${colors.default.magenta}
        palette = 13=${colors.default.magenta}
        # cyan
        palette = 6=${colors.default.cyan}
        palette = 14=${colors.default.cyan}
        # white
        palette = 7=${colors.default.white}
        palette = 15=${colors.default.white}
      '';
      target = ".config/ghostty/theme";
    };
  };
}
