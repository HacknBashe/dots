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
      gdm.enable = true;
      sddm.enable = false;
      lightdm.enable = false;
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
    dunst
    grim
    inotify-tools
    libnotify
    slurp
    swaybg
    (pkgs.waybar.overrideAttrs (oldAttrs: {
      mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
    }))
    wl-clipboard
    wlogout
    wofi
    xdg-utils
  ];
}
