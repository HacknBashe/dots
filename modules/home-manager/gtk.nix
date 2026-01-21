{
  pkgs,
  config,
  inputs,
  lib,
  ...
}: let
  # Use ANSI colors instead of base16
  c = config.theme.colors;
  baseCss = ''
    /* Color variables for themes that respect them */
    @define-color accent_color ${c.default.blue};
    @define-color accent_bg_color ${c.default.blue};
    @define-color accent_fg_color ${c.default.black};
    @define-color destructive_color ${c.default.red};
    @define-color destructive_bg_color ${c.default.red};
    @define-color destructive_fg_color ${c.default.black};
    @define-color success_color ${c.default.green};
    @define-color success_bg_color ${c.default.green};
    @define-color success_fg_color ${c.default.black};
    @define-color warning_color ${c.default.magenta};
    @define-color warning_bg_color ${c.default.magenta};
    @define-color warning_fg_color ${c.default.black};
    @define-color error_color ${c.default.red};
    @define-color error_bg_color ${c.default.red};
    @define-color error_fg_color ${c.default.black};
    @define-color window_bg_color ${c.default.black};
    @define-color window_fg_color ${c.default.white};
    @define-color view_bg_color ${c.default.black};
    @define-color view_fg_color ${c.default.white};
    @define-color headerbar_bg_color ${c.background};
    @define-color headerbar_fg_color ${c.default.white};
    @define-color theme_bg_color ${c.default.black};
    @define-color theme_fg_color ${c.default.white};
    @define-color theme_base_color ${c.default.black};
    @define-color theme_text_color ${c.default.white};
    @define-color theme_selected_bg_color ${c.default.blue};
    @define-color theme_selected_fg_color ${c.default.black};
    @define-color borders ${c.indexed.bgHighlight};
    
    /* Direct CSS overrides with !important to force colors through */
    window,
    .background {
      background-color: ${c.default.black} !important;
      color: ${c.default.white} !important;
    }
    
    headerbar,
    .titlebar {
      background-color: ${c.background} !important;
      color: ${c.default.white} !important;
    }
    
    .view,
    textview text,
    iconview,
    .content-view {
      background-color: ${c.default.black} !important;
      color: ${c.default.white} !important;
    }
    
    entry,
    .entry {
      background-color: ${c.default.black} !important;
      color: ${c.default.white} !important;
      border-color: ${c.indexed.bgHighlight} !important;
    }
    
    button {
      background-color: ${c.indexed.bgHighlight} !important;
      color: ${c.default.white} !important;
    }
    
    button:hover {
      background-color: ${c.bright.black} !important;
    }
    
    button:active,
    button:checked {
      background-color: ${c.default.blue} !important;
      color: ${c.default.black} !important;
    }
    
    .sidebar,
    sidebar {
      background-color: ${c.background} !important;
      color: ${c.default.white} !important;
    }
    
    menu,
    .menu,
    popover,
    .popover {
      background-color: ${c.background} !important;
      color: ${c.default.white} !important;
    }
    
    menuitem:hover,
    .menuitem:hover {
      background-color: ${c.default.blue} !important;
      color: ${c.default.black} !important;
    }
    
    *:selected,
    *:selected:focus {
      background-color: ${c.default.blue} !important;
      color: ${c.default.black} !important;
    }
    @define-color blue_1 ${c.default.blue};
    @define-color blue_2 ${c.default.blue};
    @define-color blue_3 ${c.default.blue};
    @define-color blue_4 ${c.default.blue};
    @define-color blue_5 ${c.default.blue};
    @define-color green_1 ${c.default.green};
    @define-color green_2 ${c.default.green};
    @define-color green_3 ${c.default.green};
    @define-color green_4 ${c.default.green};
    @define-color green_5 ${c.default.green};
    @define-color yellow_1 ${c.default.yellow};
    @define-color yellow_2 ${c.default.yellow};
    @define-color yellow_3 ${c.default.yellow};
    @define-color yellow_4 ${c.default.yellow};
    @define-color yellow_5 ${c.default.yellow};
    @define-color orange_1 ${c.indexed.orange};
    @define-color orange_2 ${c.indexed.orange};
    @define-color orange_3 ${c.indexed.orange};
    @define-color orange_4 ${c.indexed.orange};
    @define-color orange_5 ${c.indexed.orange};
    @define-color red_1 ${c.default.red};
    @define-color red_2 ${c.default.red};
    @define-color red_3 ${c.default.red};
    @define-color red_4 ${c.default.red};
    @define-color red_5 ${c.default.red};
    @define-color purple_1 ${c.default.magenta};
    @define-color purple_2 ${c.default.magenta};
    @define-color purple_3 ${c.default.magenta};
    @define-color purple_4 ${c.default.magenta};
    @define-color purple_5 ${c.default.magenta};
    @define-color brown_1 ${c.indexed.red1};
    @define-color brown_2 ${c.indexed.red1};
    @define-color brown_3 ${c.indexed.red1};
    @define-color brown_4 ${c.indexed.red1};
    @define-color brown_5 ${c.indexed.red1};
    @define-color light_1 ${c.background};
    @define-color light_2 ${c.background};
    @define-color light_3 ${c.background};
    @define-color light_4 ${c.background};
    @define-color light_5 ${c.background};
    @define-color dark_1 ${c.background};
    @define-color dark_2 ${c.background};
    @define-color dark_3 ${c.background};
    @define-color dark_4 ${c.background};
    @define-color dark_5 ${c.background};
  '';
in {
  gtk = {
    enable = true;
    # font = {
    # inherit (config.theme.fonts.sans) package name;
    # size = config.theme.fonts.sizes.applications;
    # };
    cursorTheme = {
      package = pkgs.vimix-cursors;
      name = "Vimix-Cursors";
      size = 48;
    };

    theme = {
      # adw-gtk3 provides the best balance of dark theme + respecting some color variables
      package = pkgs.adw-gtk3;
      name = "adw-gtk3-dark";
    };
    iconTheme = {
      package = pkgs.kdePackages.breeze-icons;
      name = "breeze-dark";
    };
  };

  # For GTK4/libadwaita apps, set the color scheme preference
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  xdg.configFile = {
    "gtk-3.0/gtk.css".text = baseCss;
    "gtk-4.0/gtk.css".text = baseCss;
  };
}
