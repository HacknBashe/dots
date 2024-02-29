{ config, pkgs, ... }: {
  programs.thunar.enable = true;
  programs.xfconf.enable = true;
  services.gvfs.enable = true;
  services.tumbler.enable = true;
  programs.thunar.plugins = with pkgs.xfce; [
    thunar-archive-plugin
    thunar-volman
  ];

  services.gnome.gnome-keyring.enable = true;
  programs.seahorse.enable = true;
  # For obsidian
  nixpkgs.config.permittedInsecurePackages = [ "electron-25.9.0" ];

  programs.steam.enable = true;
  environment.systemPackages = with pkgs; [
    alacritty
    brave
    drawio
    firefox
    gimp
    gparted
    helvum
    makemkv
    obs-studio
    obsidian
    prismlauncher-unwrapped
    qalculate-gtk
    qbittorrent
    qimgv
    spotify
    ungoogled-chromium
    webcord
    wezterm
    vlc
  ];
}
