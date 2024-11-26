{
  config,
  pkgs,
  lib,
  ...
}: {
  home = {
    stateVersion = "24.05"; # Please read the comment before changing.
    sessionVariables = {NIX_SHELL_PRESERVE_PROMPT = 1;};
  };

  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    (pkgs.nerdfonts.override {fonts = ["SourceCodePro"];})
    font-awesome
    raleway

    spotify
  ];

  programs = {
    home-manager.enable = true;
  };

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
      source = ../../files/config/sketchybar/sketchybarrc;
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
      source = ../../files/config/sketchybar/items;
      target = ".config/sketchybar/items";
      recursive = true;
    };
    "sketchybar/plugins" = {
      source = ../../files/config/sketchybar/plugins;
      target = ".config/sketchybar/plugins";
      recursive = true;
    };
  };

  programs.zsh.initExtra = ''
    . ~/.hubspot/shellrc
  '';

  home.activation = {
    rsync-home-manager-applications = lib.hm.dag.entryAfter ["writeBoundary"] ''
      rsyncArgs="--archive --checksum --chmod=-w --copy-unsafe-links --delete"
      apps_source="$genProfilePath/home-path/Applications"
      moniker="Home Manager Trampolines"
      app_target_base="${config.home.homeDirectory}/Applications"
      app_target="$app_target_base/$moniker"
      mkdir -p "$app_target"
      ${pkgs.rsync}/bin/rsync $rsyncArgs "$apps_source/" "$app_target"
    '';
  };

  isHubspot = true;
}
