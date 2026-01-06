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
        grace = 0;
        no_fade_in = false;
        hide_cursor = true;
      };

      background = [
        {
          monitor = "DP-3";
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
          monitor = "DP-4";
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
        monitor = "";
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
        font_family = config.theme.fonts.mono;
        position = "0, -300";
        halign = "center";
        valign = "top";
      };
    };
  };

  xdg = {
    dataFile."applications/ghostty-nvim.desktop".text = ''
      [Desktop Entry]
      Comment=Open text files in Neovim inside Ghostty
      Exec=ghostty -e nvim %F
      Icon=ghostty
      MimeType=text/plain;text/x-log
      Name=Ghostty with Neovim
      Terminal=false
      Type=Application
      Version=1.5
    '';
    mimeApps = {
      enable = true;
      defaultApplications = {
        "text/plain" = "ghostty-nvim.desktop";
        "inode/directory" = "org.kde.dolphin.desktop";
      };
    };
    # Ensure no user portal config overrides system config
    configFile."xdg-desktop-portal/portals.conf".text = ''
      # This file is managed by NixOS
      # Portal configuration is set in modules/nixos/hyprland.nix
      # User-level overrides are not used to maintain declarative configuration
    '';
  };

  home.packages = with pkgs; [
    vimix-cursors
    (whisper-cpp.override {cudaSupport = true;})
  ];

  home.file = {
    "hypr/vars.conf" = {
      text = ''
        $activeColor = ${builtins.substring 1 6 config.theme.colors.default.blue + "cc"}
        $inactiveColor = ${builtins.substring 1 6 config.theme.colors.bright.black + "99"}
        $shadowColor = ${builtins.substring 1 6 config.theme.colors.text + "ee"}

        $wallWide = ${config.theme.wallWide}
        $wallXWide = ${config.theme.wallXWide}

        $monitor1Command = ${config.monitor1Command}
        $monitor2Command = ${config.monitor2Command}

        $lockCommand = ${config.lockCommand}
      '';
      target = ".config/hypr/vars.conf";
    };
    "hypr/hyprland.conf" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/dots/files/config/hypr/hyprland.conf";
      target = ".config/hypr/hyprland.conf";
    };
    "hypr/hypridle.conf" = {
      # TODO: replace with config.lib.file.mkOutOfStoreSymlink once hypridle supports sourcing
      # source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/dots/files/config/hypr/hypridle.conf";
      text = ''
        $lockCommand = ${config.lockCommand}

        ${builtins.readFile ../../files/config/hypr/hypridle.conf}
      '';
      target = ".config/hypr/hypridle.conf";
    };
    "hypr/scripts" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/dots/files/config/hypr/scripts";
      target = ".config/hypr/scripts";
      recursive = true;
    };
    "hypr/shaders" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/dots/files/config/hypr/shaders";
      target = ".config/hypr/shaders";
      recursive = true;
    };
  };
}
