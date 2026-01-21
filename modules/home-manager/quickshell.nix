{
  pkgs,
  inputs,
  config,
  lib,
  ...
}: let
  # Generate combined quickshell configuration JSON
  nixConfig = builtins.toJSON {
    # Theme colors (ANSI colors only)
    colors = {
      # Semantic color names mapped to ANSI colors
      primary = config.theme.colors.default.magenta;     # Purple
      secondary = config.theme.colors.indexed.purple;     # Light pink
      tertiary = config.theme.colors.indexed.orange;        # Orange
      quaternary = config.theme.colors.default.yellow;   # Yellow
      quinary = config.theme.colors.default.green;       # Green
      
      # Base colors
      background = config.theme.colors.background;
      foreground = config.theme.colors.foreground;
      surface = config.theme.colors.default.black;
      surfaceContainer = config.theme.colors.indexed.bgHighlight;
      textOnBackground = config.theme.colors.foreground;
      textOnSurface = config.theme.colors.bright.white;
      textOnPrimary = config.theme.colors.background;
      outline = config.theme.colors.bright.black;
      shadow = config.theme.colors.default.black;
    };

    # Monitor configuration
    monitors = {
      monitor1Name = config.monitor1Name;
      monitor2Name = config.monitor2Name;
      barMonitor = config.monitor2Name;  # Bar shows on monitor 2
      lockCommand = config.lockCommand;
    };
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
    
    # Generate combined Nix configuration JSON for quickshell
    "quickshell-nix-config" = {
      target = ".config/quickshell/nix-config.json";
      text = nixConfig;
    };
  };
}
