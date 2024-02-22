{ config, pkgs, wallLarge, ... }: {
  nix = {
    settings = {
      substituters = [ "https://hyprland.cachix.org" ];
      trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
    };
  };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];
    displayManager = {
      sddm = {
        enable = true;
        theme = "${import ./where-sddm-theme.nix { inherit pkgs wallLarge; }}";
      };
    };
    xrandrHeads = [
      {
        output = "DP-1";
        primary = true;
      }
      {
        output = "DP-2";
        monitorConfig = ''Option "Enable" "false"'';
      }
    ];
  };

  security.pam.services.swaylock = {
    text = ''
      auth include login
    '';
  };

  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
  };

  services.dbus.enable = true;
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  environment.systemPackages = with pkgs; [
    swaybg
    swaylock-effects

    # sddm-theme dependencies
    libsForQt5.qt5ct
    libsForQt5.qt5.qtquickcontrols
    libsForQt5.qt5.qtgraphicaleffects

    dunst
    inotify-tools
    libnotify

    (pkgs.waybar.overrideAttrs (oldAttrs: {
      mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
    }))
    wlogout
    wofi

    grim
    slurp
    wl-clipboard
    xdg-utils
  ];
}
