{
  config,
  pkgs,
  inputs,
  ...
}: {
  nix = {
    settings = {
      substituters = ["https://hyprland.cachix.org"];

      trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
    };
  };

  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    xwayland.enable = true;
  };

  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
  };

  services.dbus.enable = true;
  xdg.portal = {
    enable = true;
    extraPortals = [pkgs.xdg-desktop-portal-gtk];
  };

  systemd.user = {
    targets.hyprland = {
      unitConfig = {
        Description = "Hyprland Session";
        BindsTo = ["graphical-session.target"];
        Wants = ["graphical-session-pre.target"];
        After = ["graphical-session-pre.target"];
      };
    };

    services.gnome-policykit-agent = {
      enable = true;
      description = "GNOME PolicyKit Agent";
      wantedBy = ["graphical-session.target"];
      serviceConfig = {
        Type = "simple";

        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };

  environment.systemPackages = with pkgs; [
    swaybg
    hypridle
    hyprlock
    wayland-logout

    polkit_gnome

    grim
    slurp
    wl-clipboard
    xdg-utils
  ];

  environment.etc."nix/vars.ts".text = ''
    export const MONITOR_1_COMMAND = "${config.monitor1Command}";
    export const MONITOR_2_COMMAND = "${config.monitor2Command}";
    export const TV_COMMAND = "${config.tvCommand}";
    export const LOCK_COMMAND = "${config.lockCommand}";
  '';
}
