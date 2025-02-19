{
  config,
  pkgs,
  inputs,
  ...
}: {
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

  programs.steam.enable = true;
  programs.steam.package = pkgs.steam.override {
    extraProfile = ''export LD_PRELOAD=${pkgs.extest}/lib/libextest.so:$LD_PRELOAD'';
  };

  hardware.steam-hardware.enable = true;

  environment.systemPackages = with pkgs; [
    alacritty
    brave
    drawio
    firefox
    gimp
    gparted
    helvum
    lutris
    makemkv
    obs-studio
    obsidian
    prismlauncher
    qalculate-gtk
    qbittorrent
    qimgv
    spotify
    todoist-electron
    ungoogled-chromium
    webcord
    vlc
    wine
    winetricks
  ];
}
