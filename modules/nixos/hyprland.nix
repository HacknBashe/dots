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

  services = {
    displayManager.sddm = {
      enable = true;
      theme = "${import ./where-sddm-theme.nix {inherit pkgs config;}}";
    };
    xserver = {
      enable = true;
      videoDrivers = ["nvidia"];
      xrandrHeads = [
        {
          output = "DP-2";
          primary = true;
        }
        {
          output = "DP-0";
          monitorConfig = ''Option "Enable" "false"'';
        }
        {
          output = "HDMI-0";
          monitorConfig = ''Option "Enable" "false"'';
        }
      ];
    };
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

  nixpkgs.overlays = [
    (final: prev: {
      ags = prev.ags.overrideAttrs (old: {
        buildInputs = old.buildInputs ++ [pkgs.libdbusmenu-gtk3];
      });
    })
  ];

  environment.systemPackages = with pkgs; [
    swaybg
    ags
    hyprlock

    # sddm-theme dependencies
    libsForQt5.qt5ct
    libsForQt5.qt5.qtquickcontrols
    libsForQt5.qt5.qtgraphicaleffects

    polkit_gnome

    wlogout

    wayland-logout
    wofi

    grim
    slurp
    wl-clipboard
    xdg-utils
  ];
}
