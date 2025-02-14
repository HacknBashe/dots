{
  pkgs,
  lib,
  ...
}: {
  services = {
    displayManager = {
      sddm = {
        enable = true;
        enableHidpi = true;
        theme = "where_is_my_sddm_theme";
        extraPackages = with pkgs.kdePackages; [
          qtvirtualkeyboard
          qtsvg
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
          ${lib.getBin pkgs.xorg.xrandr}/bin/xrandr --output DP-0 --off --output DP-2 --off --output HDMI-0 --off
          ${lib.getBin pkgs.xorg.xrandr}/bin/xrandr --output DP-2 --auto --primary --output HDMI-0 --noprimary --mode 1920x1080 --right-of DP-2 --output DP-0 --noprimary --mode 1920x1080 --left-of DP-2
        '';
        # ${lib.getBin pkgs.xorg.xrandr}/bin/xrandr --output HDMI-0 --noprimary --mode 1920x1080 --pos 5360x180
        # ${lib.getBin pkgs.xorg.xrandr}/bin/xrandr --output DP-0 --noprimary --mode 1920x1080 --pos 0x180
        # ${lib.getBin pkgs.xorg.xrandr}/bin/xrandr --output DP-2 --auto --primary --pos 1920x0
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
        passwordCursorColor = "#ffffff";
        sessionsFontSize = 24;
        usersFontSize = 48;
      };
    })
    wlr-randr
  ];
}
