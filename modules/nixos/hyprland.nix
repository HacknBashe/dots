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

  security.pam.services = {
    login = {
      enableKwallet = true;
    };
    kwallet = {
      enableKwallet = true;
    };
    ssdm = {
      enableKwallet = true;
      text = ''
        auth include login
      '';
    };
    hyprlock = {
      enableKwallet = true;
      text = ''
        auth include login
      '';
    };
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

    services.polkit-kde-authentication-agent-1 = {
      description = "KDE PolicyKit Authentication Agent";
      wantedBy = ["graphical-session.target"];
      partOf = ["graphical-session.target"];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.libsForQt5.polkit-kde-agent}/libexec/polkit-kde-authentication-agent";
        Restart = "on-failure";
        RestartSec = 5;
        TimeoutStopSec = 10;
      };
    };
  };

  environment.systemPackages = with pkgs; [
    swaybg
    hypridle
    hyprlock
    wayland-logout

    libsForQt5.kwallet
    libsForQt5.kwallet-pam
    libsForQt5.polkit-kde-agent

    grim
    slurp
    wl-clipboard
    wtype
    xdg-utils
  ];

  environment.etc."nix/vars.ts".text = ''
    export const MONITOR_1_COMMAND = "${config.monitor1Command}";
    export const MONITOR_2_COMMAND = "${config.monitor2Command}";
    export const MONITOR_3_COMMAND = "${config.monitor3Command}";
    export const LOCK_COMMAND = "${config.lockCommand}";
  '';
}
