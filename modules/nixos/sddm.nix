{pkgs, ...}: {
  services = {
    displayManager = {
      sddm = {
        enable = true;
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
        # wayland.enable = true;
      };
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
          monitorConfig = ''Option "LeftOf" "DP-4"'';
        }
        {
          output = "HDMI-0";
          monitorConfig = ''Option "RightOf" "DP-4"'';
        }
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    (where-is-my-sddm-theme.override {
      themeConfig.General = {
        background = "${pkgs.fetchurl {
          url = "https://raw.githubusercontent.com/NickHackford/walls/master/nebula-blue.png";
          sha256 = "ax1ooEDFT6Srk9EqzZ6Sa9DE1cVh59/MDMc1IngVCI0=";
        }}";
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
