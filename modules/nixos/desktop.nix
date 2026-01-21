{pkgs, ...}: {
  # For obsidian
  nixpkgs.config.permittedInsecurePackages = ["electron-25.9.0"];

  programs.obs-studio = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [
    brave
    firefox

    gimp
    reaper
    blender
    kdePackages.kdenlive

    gparted
    qpwgraph
    qalculate-qt
    qbittorrent

    vlc
    makemkv

    spotify
    todoist-electron
    vesktop

    wine
    winetricks
  ];
}
