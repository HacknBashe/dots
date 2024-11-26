{
  pkgs,
  config,
  lib,
  ...
}: let
in {
  options = {
    isHubspot = lib.mkOption {
      description = ''
        Enable Hubspot specific configuration
      '';
      type = lib.types.bool;
      default = false;
    };
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

      fontSans = lib.mkOption {
        description = ''
          Sans-serif font
        '';
        type = lib.types.str;
        default = "";
      };

      fontSerif = lib.mkOption {
        description = ''
          Serif font
        '';
        type = lib.types.str;
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
            background = "#000000";
            foreground = "#FFFFFF";
            default = {
              black = "#000000";
            };
          };
        '';
      };
    };
  };

  config = {
    theme = {
      wallLarge = /home/nick/Pictures/Walls/nebula-blue.png;
      wallSmall = /home/nick/Pictures/Walls/nebula-red.png;

      fontSans = "";
      fontSerif = "";
      fontMono = "SauceCodePro Nerd Font Mono";

      colors = {
        background = "#1a1b26";
        foreground = "#c0caf5";
        cursor = "#c8d3f5";
        text = "#1a1b26";
        default = {
          black = "#1b1d2b";
          red = "#ff757f";
          green = "#c3e88d";
          yellow = "#ffc777";
          blue = "#82aaff";
          magenta = "#c099ff";
          cyan = "#86e1fc";
          white = "#828bb8";
        };
        bright = {
          black = "#444a73";
          red = "#ff757f";
          green = "#c3e88d";
          yellow = "#ffc777";
          blue = "#82aaff";
          magenta = "#c099ff";
          cyan = "#86e1fc";
          white = "#c8d3f5";
        };
        indexed = {
          one = "#ff966c";
          two = "#c53b53";
        };

        base16 = {
          base00 = "#16161e";
          base01 = "#1a1b26";
          base02 = "#2f3549";
          base03 = "#444b6a";
          base04 = "#787c99";
          base05 = "#787c99";
          base06 = "#cbccd1";
          base07 = "#d5d6db";
          base08 = "#ff757f";
          base09 = "#ff9e64";
          base0A = "#ffc777";
          base0B = "#41a6b5";
          base0C = "#86e1fc";
          base0D = "#82aaff";
          base0E = "#bb9af7";
          base0F = "#d18616";
        };
      };
    };
  };
}
