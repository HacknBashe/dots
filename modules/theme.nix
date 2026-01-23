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

    monitor1Name = lib.mkOption {
      description = ''
        Name of monitor 1 (e.g., DP-3)
      '';
      type = lib.types.str;
      default = "";
    };

    monitor2Name = lib.mkOption {
      description = ''
        Name of monitor 2 (e.g., DP-4)
      '';
      type = lib.types.str;
      default = "";
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
    monitor1Name = "DP-4";
    monitor2Name = "DP-3";
    monitor1Command = "DP-4,3440x1440,0x180,1";
    monitor2Command = "DP-3,3840x2160,3440x0,1.33";
    lockCommand = "grim -o DP-4 -l 0 /tmp/hyprlock_screenshot1.png & grim -o DP-3 -l 0 /tmp/hyprlock_screenshot2.png & wait && hyprlock";

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
        # Night background + Moon colors
        background = "#1a1b26";
        foreground = "#c8d3f5";
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
          red = "#ff8d94";
          green = "#c7fb6d";
          yellow = "#ffd8ab";
          blue = "#9ab8ff";
          magenta = "#caabff";
          cyan = "#b2ebff";
          white = "#c8d3f5";
        };
        indexed = {
          orange = "#ff966c";
          red1 = "#c53b53"; # Error color
          purple = "#fca7ea"; # Pink-ish, per folke's naming
          bgHighlight = "#2f334d";
        };
        extended = {
          # Blues
          blue0 = "#3e68d7"; # Search bg
          blue1 = "#65bcff"; # Types, border highlight
          blue2 = "#0db9d7"; # Info diagnostics
          blue5 = "#89ddff"; # Operators, punctuation
          # Greens
          green1 = "#4fd6be"; # Properties, teal
          green2 = "#41a6b5"; # Hints
          # Other
          magenta2 = "#ff007c"; # Flash, emphasis
          comment = "#636da6";
          dark3 = "#545c7e"; # Dimmed text
          dark5 = "#737aa2"; # Concealed
          fgGutter = "#3b4261"; # Line numbers
          # Night variant backgrounds
          bgDark = "#16161e"; # Sidebars, floats
        };
      };
    };
  };
}
