{config, ...}: {
  home.file = {
    "aerospace/aerospace.toml" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/dots/files/config/aerospace/aerospace.toml";
      target = ".config/aerospace/aerospace.toml";
    };

    "sketchybarrc" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/dots/files/config/sketchybar/sketchybarrc";
      target = ".config/sketchybar/sketchybarrc";
    };
    "sketchybar/colors.sh" = {
      text = ''
        #!/bin/bash

        export BAR_COLOR=0x99${builtins.substring 1 7 config.theme.colors.background}
        export FG_COLOR=0xffffffff
        export SELECTED_COLOR=0xff${builtins.substring 1 7 config.theme.colors.bright.cyan}
        export WARNING_COLOR=0xff${builtins.substring 1 7 config.theme.colors.bright.yellow}
      '';
      target = ".config/sketchybar/colors.sh";
    };
    "sketchybar/items" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/dots/files/config/sketchybar/items";
      target = ".config/sketchybar/items";
      recursive = true;
    };
    "sketchybar/plugins" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/dots/files/config/sketchybar/plugins";
      target = ".config/sketchybar/plugins";
      recursive = true;
    };
  };
}
