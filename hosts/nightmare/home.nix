{pkgs, ...}: {
  # Disable heavy dev tools we don't need on this machine
  development.enableRust = false;
  development.enablePython = false;
  development.enableJava = false;

  home.username = "nick";
  home.homeDirectory = "/home/nick";
  home.stateVersion = "25.05";

  home.packages = with pkgs; [
    gcompris
  ];

  dconf.settings = {
    "org/gnome/desktop/screensaver" = {
      lock-enabled = false;
      lock-delay = 0;
      ubuntu-lock-on-suspend = false;
    };
    "org/gnome/desktop/session" = {
      idle-delay = 180;
    };
    "org/gnome/settings-daemon/plugins/power" = {
      power-button-action = "suspend";
    };

  };

  # Hide desktop entries from app menu
  xdg.desktopEntries = {
    btop = {
      name = "btop++";
      noDisplay = true;
    };
    nvim = {
      name = "Neovim";
      noDisplay = true;
    };
    vim = {
      name = "Vim";
      noDisplay = true;
    };
    gvim = {
      name = "GVim";
      noDisplay = true;
    };
    yazi = {
      name = "Yazi";
      noDisplay = true;
    };
    nixos-manual = {
      name = "NixOS Manual";
      noDisplay = true;
    };
    "org.gnome.Extensions" = {
      name = "Extensions";
      noDisplay = true;
    };
    "org.gnome.Shell.Extensions" = {
      name = "Shell Extensions";
      noDisplay = true;
    };
    "org.gnome.Tour" = {
      name = "Tour";
      noDisplay = true;
    };
    brave-browser = {
      name = "Brave";
      noDisplay = true;
    };
    # Web shortcuts
    sesame-street-games = {
      name = "Sesame Street Games";
      comment = "Educational games with Sesame Street characters";
      exec = "brave --kiosk https://www.sesamestreet.org/games";
      icon = "applications-games";
      terminal = false;
      categories = ["Game" "Education"];
    };
    chrome-music-lab = {
      name = "Chrome Music Lab";
      comment = "Music creation and learning experiments";
      exec = "brave --kiosk https://musiclab.chromeexperiments.com";
      icon = "applications-multimedia";
      terminal = false;
      categories = ["AudioVideo" "Education"];
    };
  };
}
