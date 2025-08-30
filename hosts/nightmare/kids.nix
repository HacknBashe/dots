{pkgs, ...}: {
  home.username = "kids";
  home.homeDirectory = "/home/kids";
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;
  home.packages = with pkgs; [
    gcompris
    kdePackages.ktuberling
  ];

  # Disable lock screen and force fullscreen for kids user
  dconf.settings = {
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

  # Hide unwanted apps from the application drawer and add web app
  home.file = {
    # Sesame Street Games
    ".local/share/applications/sesame-street-games.desktop".text = ''
      [Desktop Entry]
      Version=1.0
      Type=Application
      Name=Sesame Street Games
      Comment=Educational games with Sesame Street characters
      Exec=firefox --kiosk https://www.sesamestreet.org/games
      Icon=applications-games
      Terminal=false
      Categories=Game;Education;
      StartupNotify=true
    '';
    # Chrome Music Lab
    ".local/share/applications/chrome-music-lab.desktop".text = ''
      [Desktop Entry]
      Version=1.0
      Type=Application
      Name=Chrome Music Lab
      Comment=Music creation and learning experiments
      Exec=firefox --kiosk https://musiclab.chromeexperiments.com
      Icon=applications-multimedia
      Terminal=false
      Categories=AudioVideo;Education;
      StartupNotify=true
    '';
    # Hide system apps kids don't need
    ".local/share/applications/firefox.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Firefox
      NoDisplay=true
    '';
    ".local/share/applications/org.gnome.Extensions.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Extensions
      NoDisplay=true
    '';
    ".local/share/applications/org.gnome.Settings.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Settings
      NoDisplay=true
    '';
    ".local/share/applications/org.gnome.Tour.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Tour
      NoDisplay=true
    '';
    ".local/share/applications/nixos-manual.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=NixOS Manual
      NoDisplay=true
    '';
    ".local/share/applications/org.gnome.Terminal.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Terminal
      NoDisplay=true
    '';
    ".local/share/applications/org.gnome.TextEditor.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Text Editor
      NoDisplay=true
    '';
    ".local/share/applications/org.gnome.FileRoller.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Archive Manager
      NoDisplay=true
    '';
  };
}
