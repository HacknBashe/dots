{pkgs, ...}: {
  programs.thunar.enable = true;
  programs.xfconf.enable = true;
  services.gvfs.enable = true;
  services.tumbler.enable = true;
  programs.thunar.plugins = with pkgs; [
    xfce.thunar-archive-plugin
    xfce.thunar-volman
    file-roller
  ];

  # For obsidian
  nixpkgs.config.permittedInsecurePackages = ["electron-25.9.0"];

  programs.obs-studio = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [
    kdePackages.dolphin
    kdePackages.gwenview

    brave
    drawio
    firefox
    gimp
    gparted
    helvum
    makemkv
    qalculate-gtk
    qbittorrent
    qimgv
    spotify
    todoist-electron
    vesktop
    vlc
    wine
    winetricks
  ];
}
