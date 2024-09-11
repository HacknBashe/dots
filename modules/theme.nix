{
  pkgs,
  config,
  lib,
  ...
}: let
in {
  options = {
    theme = {
      wallLarge = lib.mkOption {
        description = ''
          Extra wide wallpaper
        '';
        type = lib.types.path;
        default = "";
      };

      wallSmall = lib.mkOption {
        description = ''
          Standard wallpaper
        '';
        type = lib.types.path;
        default = "";
      };

      fontMono = lib.mkOption {
        description = ''
          Monospace font
        '';
        type = lib.types.str;
        default = "";
      };

      colors = lib.mkOption {
        description = ''
          Custom colors to theme applications with
        '';
        type = lib.types.attrsOf (lib.types.either lib.types.str (lib.types.attrsOf lib.types.str));
        default = {};
        example = ''
          // Color definitions
          colors = {
            background = "#1a1b26";
            foreground = "#c0caf5";
            default = {
              black = "#15161e";
            };
          };
        '';
      };
    };
  };

  config = {
    theme = {
      wallLarge = /home/nick/Pictures/Walls/glowshroom-large.jpg;
      wallSmall = /home/nick/Pictures/Walls/glowshroom-small.jpg;

      fontMono = "SauceCodePro Nerd Font Mono";

      colors = {
        background = "#1a1b26";
        foreground = "#c0caf5";
        cursor = "#c0caf5";
        text = "#1a1b26";
        default = {
          black = "#15161e";
          red = "#f7768e";
          green = "#9ece6a";
          yellow = "#e0af68";
          blue = "#7aa2f7";
          magenta = "#bb9af7";
          cyan = "#7dcfff";
          white = "#a9b1d6";
        };
        bright = {
          black = "#414868";
          red = "#f7768e";
          green = "#9ece6a";
          yellow = "#e0af68";
          blue = "#7aa2f7";
          magenta = "#bb9af7";
          cyan = "#7dcfff";
          white = "#c0caf5";
        };
        indexed = {
          one = "#ff9e64";
          two = "#db4b4b";
        };
      };
    };
  };
}
