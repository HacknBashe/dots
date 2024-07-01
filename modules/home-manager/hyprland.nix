{
  config,
  pkgs,
  colors,
  wallSmall,
  wallLarge,
  ...
}: {
  services.dunst.enable = true;
  home.file = {
    "hypr" = {
      # source = ../../files/config/hypr/hyprland.conf;
      text = ''
        $activeColor = ${builtins.substring 1 6 colors.default.blue + "cc"}
        $inactiveColor = ${builtins.substring 1 6 colors.bright.black + "99"}
        $shadowColor = ${builtins.substring 1 6 colors.text + "ee"}

        exec = swaybg -o DP-4 -i ${wallLarge}
        exec = swaybg -o DP-3 -i ${wallSmall}
        ${builtins.readFile ../../files/config/hypr/hyprland.conf}
      '';
      target = ".config/hypr/hyprland.conf";
    };
    "hypr/scripts" = {
      source = ../../files/config/hypr/scripts;
      target = ".config/hypr/scripts";
      recursive = true;
    };
    "hypr/shaders" = {
      source = ../../files/config/hypr/shaders;
      target = ".config/hypr/shaders";
      recursive = true;
    };

    "waybar" = {
      source = ../../files/config/waybar;
      target = ".config/waybar";
      recursive = true;
    };
    "waybar/scheme.css" = {
      text = ''
        @define-color bgnone alpha(${colors.background},0);
        @define-color bg0 alpha(${colors.background},1);
        @define-color bg1 alpha(${colors.background},.9);
        @define-color bg2 alpha(${colors.background},.7);
        @define-color bg3 alpha(${colors.background},.5);
        @define-color fg0 alpha(${colors.foreground},1);
        @define-color fg1 alpha(${colors.foreground},.9);
        @define-color fg2 alpha(${colors.foreground},.7);
        @define-color fg3 alpha(${colors.foreground},.5);
      '';
      target = ".config/waybar/scheme.css";
    };
    "waybar/scripts" = {
      source = ../../files/config/waybar/scripts;
      target = ".config/waybar/scripts";
      recursive = true;
    };

    "wofi" = {
      source = ../../files/config/wofi/style.css;
      target = ".config/wofi/style.css";
    };

    "wlogout.files" = {
      source = ../../files/config/wlogout;
      target = ".config/wlogout";
      recursive = true;
    };
    "wlogout.style" = {
      target = ".config/wlogout/style.css";
      text = ''
        * {
          background-image: none;
        }

        window {
          font-size: 50pt;
          background-color: ${colors.background}50;
        }

        button {
          color: ${colors.text};
          border: none;
          box-shadow: none;
          background-repeat: no-repeat;
          background-position: center;
          background-size: 25%;
          background-color: ${colors.background}00;
          margin: 0px;
          transition: background-color 0.2s ease-in-out;
        }

        button:hover {
          background-color: ${colors.default.blue}10;
        }

        button:focus {
          background-color: ${colors.default.blue}30;
        }

        #lock {
          background-image: image(url("./lock.png"));
        }

        #suspend {
          background-image: image(url("./sleep.png"));
        }

        #hibernate {
          background-image: image(url("./sleep.png"));
        }

        #logout {
          background-image: image(url("./logout.png"));
        }

        #shutdown {
          background-image: image(url("./power.png"));
        }

        #reboot {
          background-image: image(url("./restart.png"));
        }
      '';
    };
  };
}
