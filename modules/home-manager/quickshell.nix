{
  pkgs,
  inputs,
  config,
  lib,
  ...
}: let
  # Generate colors JSON from theme config (ANSI colors only)
  themeColors = builtins.toJSON {
    # Semantic color names mapped to ANSI colors
    primary = config.theme.colors.default.magenta;     # Purple
    secondary = config.theme.colors.indexed.three;     # Light pink
    tertiary = config.theme.colors.indexed.one;        # Orange
    quaternary = config.theme.colors.default.yellow;   # Yellow
    quinary = config.theme.colors.default.green;       # Green
    
    # Base colors
    background = config.theme.colors.background;
    foreground = config.theme.colors.foreground;
    surface = config.theme.colors.default.black;
    surfaceContainer = "#2f334f";  # Middle ground between default.black and bright.black
    textOnBackground = config.theme.colors.foreground;
    textOnSurface = config.theme.colors.bright.white;
    textOnPrimary = config.theme.colors.background;
    outline = config.theme.colors.bright.black;
    shadow = config.theme.colors.default.black;
  };
in {
  home.packages = [
    inputs.quickshell.packages.${pkgs.system}.default
    inputs.caelestia-shell.packages.${pkgs.system}.default
    pkgs.qt6.qtdeclarative # Provides qmlformat
  ];

  home.file = {
    "nick" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/dots/files/config/quickshell/nick";
      target = ".config/quickshell/nick";
      recursive = true;
    };
    
    # Generate theme colors JSON
    "quickshell-colors" = {
      target = ".config/quickshell/theme-colors.json";
      text = themeColors;
    };
  };

  # Set environment variable for lock command
  home.sessionVariables = {
    LOCK_COMMAND = config.lockCommand;
  };
}
