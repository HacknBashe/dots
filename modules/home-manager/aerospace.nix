{config, ...}: {
  home.file = {
    "aerospace/aerospace.toml" = {
      text = ''
        after-startup-command = [
          'exec-and-forget borders active_color=0xff${builtins.substring 1 6 config.theme.colors.default.cyan} inactive_color=0xff${builtins.substring 1 6 config.theme.colors.default.white} width=10.0',
          'exec-and-forget sketchybar'
        ]
        ${builtins.readFile ../../files/config/aerospace/aerospace.toml}
      '';
      target = ".config/aerospace/aerospace.toml";
    };

    "sketchybarrc" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.homeDirPath}.config/dots/files/config/sketchybar/sketchybarrc";
      target = ".config/sketchybar/sketchybarrc";
    };
    "sketchybar/colors.sh" = {
      text = ''
        #!/bin/bash

        export WHITE=0xffffffff

        export BAR_COLOR=0xff${builtins.substring 1 7 config.theme.colors.background}

        export ITEM_BG_COLOR=0xff${builtins.substring 1 7 config.theme.colors.bright.black}
        export ACCENT_COLOR=0xff${builtins.substring 1 7 config.theme.colors.bright.white}
      '';
      target = ".config/sketchybar/colors.sh";
    };
    "sketchybar/items" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.homeDirPath}.config/dots/files/config/sketchybar/items";
      target = ".config/sketchybar/items";
      recursive = true;
    };
    "sketchybar/plugins" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.homeDirPath}.config/dots/files/config/sketchybar/plugins";
      target = ".config/sketchybar/plugins";
      recursive = true;
    };
  };
}
