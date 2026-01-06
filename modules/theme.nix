{lib, ...}: let
in {
  options = {
    isHubspot = lib.mkOption {
      description = ''
        Enable Hubspot specific configuration
      '';
      type = lib.types.bool;
      default = false;
    };

    monitor1Command = lib.mkOption {
      description = ''
        Hyprland command for monitor 1
      '';
      type = lib.types.str;
      default = "";
    };

    monitor2Command = lib.mkOption {
      description = ''
        Hyprland command for monitor 2
      '';
      type = lib.types.str;
      default = "";
    };

    lockCommand = lib.mkOption {
      description = ''
        Command to lock the screen
      '';
      type = lib.types.str;
      default = "";
    };

    theme = {
      wallWide = lib.mkOption {
        description = ''
          Wide wallpaper
        '';
        type = lib.types.str;
        default = "";
      };

      wallXWide = lib.mkOption {
        description = ''
          Extra wide wallpaper
        '';
        type = lib.types.str;
        default = "";
      };

      fonts = {
        sans = lib.mkOption {
          description = ''
            Sans-serif font
          '';
          type = lib.types.str;
          default = "";
        };

        serif = lib.mkOption {
          description = ''
            Serif font
          '';
          type = lib.types.str;
          default = "";
        };

        mono = lib.mkOption {
          description = ''
            Monospace font
          '';
          type = lib.types.str;
          default = "";
        };

        sizes = lib.mkOption {
          description = ''
            Font sizes for different contexts
          '';
          type = lib.types.attrsOf lib.types.int;
          default = {};
          example = ''
            {
              applications = 12;
            }
          '';
        };
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
    monitor1Command = "DP-3,3840x2160,3440x0,2";
    monitor2Command = "DP-4,3440x1440,0x180,1";
    lockCommand = "grim -o DP-3 -l 0 /tmp/hyprlock_screenshot1.png & grim -o DP-4 -l 0 /tmp/hyprlock_screenshot2.png & wait && hyprlock";

    theme = {
      wallWide = "/home/nick/Pictures/Walls/nebula-red.png";
      wallXWide = "/home/nick/Pictures/Walls/nebula-blue.png";

      fonts = {
        sans = "";
        serif = "";
        mono = "SauceCodePro Nerd Font Mono";
        sizes = {
          applications = 12;
        };
      };

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
          one = "#ff966c";    # Orange
          two = "#c53b53";    # Dark red
          three = "#ffb3d9";  # Pastel retrowave pink
          four = "#2f3549";   # Mid-tone background (for buttons, hover states)
        };
      };
    };
  };
}
