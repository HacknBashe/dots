{
  config,
  pkgs,
  colors,
  wallSmall,
  wallLarge,
  ...
}: {
  home.file = {
    "hypr" = {
      # source = ../../files/config/hypr/hyprland.conf;
      text = ''
        $activeColor = ${builtins.substring 1 6 colors.default.blue + "cc"}
        $inactiveColor = ${builtins.substring 1 6 colors.bright.black + "99"}
        $shadowColor = ${builtins.substring 1 6 colors.text + "ee"}

        exec = swaybg -o DP-4 -i ${wallLarge}
        exec = swaybg -o DP-3 -i ${wallSmall}
        exec = swaybg -o HDMI-A-5 -i ${wallSmall}
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
        @define-color bg alpha(${colors.background},1);
        @define-color bg80 alpha(${colors.background},.8);
        @define-color bg60 alpha(${colors.background},.6);
        @define-color bg0 alpha(${colors.background},0);
        @define-color fg alpha(${colors.foreground},1);
        @define-color fg80 alpha(${colors.foreground},.8);
        @define-color fg60 alpha(${colors.foreground},.6);
        @define-color white80 alpha(${colors.bright.white},.8);
      '';
      target = ".config/waybar/scheme.css";
    };
    "waybar/scripts" = {
      source = ../../files/config/waybar/scripts;
      target = ".config/waybar/scripts";
      recursive = true;
    };

    "wofi" = {
      text = ''
        window {
          background-color: ${colors.background};
          color: ${colors.foreground};
        }

        #entry:nth-child(odd) {
          background-color: ${colors.background};
        }

        #entry:nth-child(even) {
          background-color: ${colors.background};
        }

        #entry:selected {
          background-color: ${colors.bright.black};
        }

        #input {
          margin: 5px;
          background-color: ${colors.background};
          color: ${colors.foreground};
          border-color: ${colors.bright.black};
        }

        #input:focus {
          border-color: ${colors.foreground};
        }

        #inner-box {
          margin: 5px;
        }

        #outer-box {
          margin: 5px;
        }

        #scroll {
          margin: 0px;
        }

        #text {
          margin: 5px;
        }
      '';
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
          background-color: alpha(${colors.background},.5);
        }

        button {
          color: ${colors.foreground};
          border: none;
          box-shadow: none;
          background-repeat: no-repeat;
          background-position: center;
          background-size: 25%;
          background-color: alpha(${colors.background},0);
          margin: 0px;
          transition: background-color 0.2s ease-in-out;
        }

        button:hover {
          background-color: alpha(${colors.default.blue},.1);
        }

        button:focus {
          background-color: alpha(${colors.default.blue},.3);
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
