{ config, pkgs, ... }:

with config.lib.stylix.colors;

{
  services.dunst.enable = true;
  home.file = {
    "hypr" = {
      # source = ../../files/config/hypr/hyprland.conf;
      text = ''
        $activeColor = ${base0B}
        $inactiveColor = ${base03}
        $shadowColor = ${base01}
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
        @define-color base00 ${withHashtag.base00};
        @define-color base01 ${withHashtag.base01};
        @define-color base02 ${withHashtag.base02};
        @define-color base03 ${withHashtag.base03};
        @define-color base04 ${withHashtag.base04};
        @define-color base05 ${withHashtag.base05};
        @define-color base06 ${withHashtag.base06};
        @define-color base07 ${withHashtag.base07};
        @define-color base08 ${withHashtag.base08};
        @define-color base09 ${withHashtag.base09};
        @define-color base0A ${withHashtag.base0A};
        @define-color base0B ${withHashtag.base0B};
        @define-color base0C ${withHashtag.base0C};
        @define-color base0D ${withHashtag.base0D};
        @define-color base0E ${withHashtag.base0E};
        @define-color base0F ${withHashtag.base0F};
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
          background-color: rgba(${base00-rgb-r},${base00-rgb-g},${base00-rgb-b}, 0.5);
        }

        button {
          color: ${withHashtag.base07};
          border: none;
          box-shadow: none;
          background-repeat: no-repeat;
          background-position: center;
          background-size: 25%;
          background-color: rgba(${base0D-rgb-r},${base0D-rgb-g},${base0D-rgb-b}, 0);
          margin: 0px;
          transition: background-color 0.2s ease-in-out;
        }

        button:hover {
          background-color: rgba(${base0D-rgb-r},${base0D-rgb-g},${base0D-rgb-b}, 0.1);
        }

        button:focus {
          background-color: rgba(${base0D-rgb-r},${base0D-rgb-g},${base0D-rgb-b}, 0.3);
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
