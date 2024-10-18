{
  config,
  pkgs,
  inputs,
  ...
}: {
  programs.hyprlock = {
    enable = true;
    package = inputs.hyprlock.packages.${pkgs.system}.hyprlock;
    settings = {
      general = {
        grace = 3;
        no_fade_in = false;
        hide_cursor = true;
      };

      background = [
        {
          monitor = "DP-4";
          path = "/tmp/hyprlock_screenshot1.png";
          blur_passes = 1;
          blur_size = 8;
          noise = 0.0117;
          contrast = 0.8916;
          brightness = 0.8172;
          vibrancy = 0.1696;
          vibrancy_darkness = 0.0;
        }
        {
          monitor = "DP-3";
          path = "/tmp/hyprlock_screenshot2.png";
          blur_passes = 1;
          blur_size = 8;
          noise = 0.0117;
          contrast = 0.8916;
          brightness = 0.8172;
          vibrancy = 0.1696;
          vibrancy_darkness = 0.0;
        }
      ];

      input-field = {
        monitor = "DP-4";
        size = "250, 60";
        outline_thickness = 2;
        dots_size = 0.2; # Scale of input-field height, 0.2 - 0.8
        dots_spacing = 0.2; # Scale of dots' absolute size, 0.0 - 1.0
        dots_center = true;
        outer_color = "rgba(0, 0, 0, 0)";
        inner_color = "rgba(0, 0, 0, 0.5)";
        font_color = "rgb(200, 200, 200)";
        fade_on_empty = false;
        placeholder_text = ''
          <i><span foreground="##cdd6f4">󰌆 </span></i>
        '';
        hide_input = false;
        position = "0, -120";
        halign = "center";
        valign = "center";
      };

      # TIME
      label = {
        monitor = "";
        text = ''
          cmd[update:1000] echo "$(date +"%H:%M")"
        '';
        color = "rgba(205, 214, 244, 1)";
        font_size = 120;
        font_family = config.theme.fontMono;
        position = "0, -300";
        halign = "center";
        valign = "top";
      };
    };
  };

  home.packages = with pkgs; [
    vimix-cursor-theme
  ];

  home.file = {
    "hypr" = {
      # source = ../../files/config/hypr/hyprland.conf;
      text = ''
        $activeColor = ${builtins.substring 1 6 config.theme.colors.default.blue + "cc"}
        $inactiveColor = ${builtins.substring 1 6 config.theme.colors.bright.black + "99"}
        $shadowColor = ${builtins.substring 1 6 config.theme.colors.text + "ee"}

        exec = swaybg -o DP-4 -i ${config.theme.wallLarge}
        exec = swaybg -o DP-3 -i ${config.theme.wallSmall}
        exec = swaybg -o HDMI-A-5 -i ${config.theme.wallSmall}
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

    "ags" = {
      source = ../../files/config/ags;
      target = ".config/ags";
      recursive = true;
    };
    # TODO: USE for Ags?
    # "waybar/scheme.css" = {
    #   text = ''
    #     @define-color bg alpha(${config.theme.colors.background},1);
    #     @define-color bg80 alpha(${config.theme.colors.background},.8);
    #     @define-color bg60 alpha(${config.theme.colors.background},.6);
    #     @define-color bg0 alpha(${config.theme.colors.background},0);
    #     @define-color fg alpha(${config.theme.colors.foreground},1);
    #     @define-color fg80 alpha(${config.theme.colors.foreground},.8);
    #     @define-color fg60 alpha(${config.theme.colors.foreground},.6);
    #     @define-color white80 alpha(${config.theme.colors.bright.white},.8);
    #   '';
    #   target = ".config/waybar/scheme.css";
    # };

    "wofi" = {
      text = ''
        window {
          background-color: ${config.theme.colors.background};
          color: ${config.theme.colors.foreground};
        }

        #entry:nth-child(odd) {
          background-color: ${config.theme.colors.background};
        }

        #entry:nth-child(even) {
          background-color: ${config.theme.colors.background};
        }

        #entry:selected {
          background-color: ${config.theme.colors.bright.black};
        }

        #input {
          margin: 5px;
          background-color: ${config.theme.colors.background};
          color: ${config.theme.colors.foreground};
          border-color: ${config.theme.colors.bright.black};
        }

        #input:focus {
          border-color: ${config.theme.colors.foreground};
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
          background-color: alpha(${config.theme.colors.background},.5);
        }

        button {
          color: ${config.theme.colors.foreground};
          border: none;
          box-shadow: none;
          background-repeat: no-repeat;
          background-position: center;
          background-size: 25%;
          background-color: alpha(${config.theme.colors.background},0);
          margin: 0px;
          transition: background-color 0.2s ease-in-out;
        }

        button:hover {
          background-color: alpha(${config.theme.colors.default.blue},.1);
        }

        button:focus {
          background-color: alpha(${config.theme.colors.default.blue},.3);
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
