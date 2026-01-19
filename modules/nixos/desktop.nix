{pkgs, ...}: {
  # For obsidian
  nixpkgs.config.permittedInsecurePackages = ["electron-25.9.0"];

  programs.obs-studio = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [
    brave
    drawio
    firefox
    gimp
    gparted
    qpwgraph
    makemkv
    qalculate-qt
    qbittorrent
    qimgv
    reaper
    spotify
    todoist-electron
    vesktop
    vlc
    wine
    winetricks
  ];
}
