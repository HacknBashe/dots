{ config, pkgs, ... }: {
  home.file = {
    "hypr" = {
      source = ../../files/config/hypr/hyprland.conf;
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
    "waybar/scripts" = {
      source = ../../files/config/waybar/scripts;
      target = ".config/waybar/scripts";
      recursive = true;
    };

    "wofi" = {
      source = ../../files/config/wofi/style.css;
      target = ".config/wofi/style.css";
    };

    "wlogout" = {
      source = ../../files/config/wlogout;
      target = ".config/wlogout";
      recursive = true;
    };
  };
}
