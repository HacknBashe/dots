{
  pkgs,
  lib,
  config,
  ...
}: {
  services = {
    displayManager = {
      sddm = {
        package = pkgs.kdePackages.sddm;
        enable = true;
        enableHidpi = true;
        theme = "where_is_my_sddm_theme";
        extraPackages = with pkgs.kdePackages; [
          qtvirtualkeyboard
          qtsvg
          qt5compat
        ];
        settings = {
          General = {
            InputMethod = "";
          };
        };
        wayland.enable = false;
      };
    };
    xserver = {
      enable = true;
      videoDrivers = ["nvidia"];
      displayManager = {
        setupCommands = ''
          # Capture xrandr state during SDDM startup for debugging
          ${lib.getBin pkgs.xorg.xrandr}/bin/xrandr --listmonitors > /tmp/sddm-xrandr-monitors.log 2>&1
          
          ${lib.getBin pkgs.xorg.xrandr}/bin/xrandr --output DP-0 --off --output HDMI-0 --off
          ${lib.getBin pkgs.xorg.xrandr}/bin/xrandr --output DP-2 --auto --primary --output DP-0 --noprimary --mode 1920x1080 --left-of DP-2
        '';
      };
    };
  };

  environment.systemPackages = with pkgs; [
    (where-is-my-sddm-theme.override {
      themeConfig.General = {
        background = "${pkgs.fetchurl {
          url = "https://raw.githubusercontent.com/NickHackford/walls/master/nebula-blue.png";
          sha256 = "ax1ooEDFT6Srk9EqzZ6Sa9DE1cVh59/MDMc1IngVCI0=";
        }}";
        backgroundFillMode = "pad";
        passwordCharacter = "•";
        passwordFontSize = 96;
        passwordCursorColor = config.theme.colors.cursor;
        sessionsFontSize = 24;
        usersFontSize = 48;
      };
    })
    wlr-randr
  ];
}
