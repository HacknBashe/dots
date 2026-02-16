{pkgs, ...}: let
  icons = {
    sesame-street = builtins.fetchurl {
      url = "https://www.sesamestreet.org/favicon.ico";
      sha256 = "03q0sw0dhvm4cfb6m7lhf546ngyinxpcgchrcxg9kaw7iij3hlp1";
    };
    chrome-music-lab = builtins.fetchurl {
      url = "https://musiclab.chromeexperiments.com/static/MusicBox_32.ico.png";
      sha256 = "1afzcj4fdw3hk42yfjyygalzqxzbgckkyl5qhrmhfpchzbv36q4z";
    };
    starfall = builtins.fetchurl {
      url = "https://www.starfall.com/apple-touch-icon.png";
      sha256 = "0zkzq4lhqy1qdbg7a6svrlj2fkzb7rdyfnbp4jcf70slhwznxmzr";
    };
    abcya = builtins.fetchurl {
      url = "https://www.abcya.com/static/assets/apple-touch-icon.png";
      sha256 = "1fvhld1m7lyf3ymn3h6wfga0bxvvlyn2n7477zb5sf5ds9k9zi0q";
    };
    jellyfin = builtins.fetchurl {
      url = "https://raw.githubusercontent.com/jellyfin/jellyfin-ux/master/branding/SVG/icon-transparent.svg";
      sha256 = "1lama94kbqxv60ha2nn77ccfjpr6bz6lizj80hjr5ca2fjs2az41";
    };
  };
in {
  # Disable heavy dev tools we don't need on this machine
  development.enableRust = false;
  development.enablePython = false;
  development.enableJava = false;

  home.username = "nick";
  home.homeDirectory = "/home/nick";
  home.stateVersion = "25.05";

  home.packages = with pkgs; [
    gcompris
    tuxtype
    rili
  ];

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      clock-format = "12h";
    };
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
    # Hide GNOME Settings
    "org.gnome.Settings" = {
      name = "Settings";
      noDisplay = true;
    };
    # Web shortcuts
    sesame-street-games = {
      name = "Sesame Street Games";
      comment = "Educational games with Sesame Street characters";
      exec = "brave --kiosk https://www.sesamestreet.org/games";
      icon = "${icons.sesame-street}";
      terminal = false;
      categories = ["Game" "Education"];
    };
    chrome-music-lab = {
      name = "Chrome Music Lab";
      comment = "Music creation and learning experiments";
      exec = "brave --kiosk https://musiclab.chromeexperiments.com";
      icon = "${icons.chrome-music-lab}";
      terminal = false;
      categories = ["AudioVideo" "Education"];
    };
    starfall = {
      name = "Starfall";
      comment = "Reading and phonics learning games";
      exec = "brave --kiosk https://www.starfall.com";
      icon = "${icons.starfall}";
      terminal = false;
      categories = ["Game" "Education"];
    };
    abcya = {
      name = "ABCya";
      comment = "Educational games for kids";
      exec = "brave --kiosk https://www.abcya.com";
      icon = "${icons.abcya}";
      terminal = false;
      categories = ["Game" "Education"];
    };
    jellyfin = {
      name = "Jellyfin";
      comment = "Watch TV and movies";
      exec = "brave --kiosk https://www.tv.hackford.us";
      icon = "${icons.jellyfin}";
      terminal = false;
      categories = ["AudioVideo"];
    };
  };
}
