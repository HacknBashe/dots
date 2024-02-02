{ config, pkgs, ... }:
let
  # FIXME: this needs to be dynamic based on the host if I want to reuse this
  monitorsXmlContent = builtins.readFile ../../hosts/meraxes/monitors.xml;
  monitorsConfig = pkgs.writeText "gdm_monitors.xml" monitorsXmlContent;
in {
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
    layout = "us";
    xkbVariant = "";
    videoDrivers = [ "nvidia" ];
    displayManager = {
      # gdm.enable = false;
      sddm.enable = true;
      sddm.theme = "${import ./sddm-theme.nix { inherit pkgs; }}";
      # autoLogin = {
      #   enable = true;
      #   user = "nick";
      # };
    };
  };
  systemd.tmpfiles.rules =
    [ "L+ /run/gdm/.config/monitors.xml - - - - ${monitorsConfig}" ];

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
