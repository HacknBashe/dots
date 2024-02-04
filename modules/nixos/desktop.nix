{ config, pkgs, ... }: {
  # programs.thunar.enable = true;
  # programs.xfconf.enable = true;
  # services.gvfs.enable = true;
  # services.tumbler.enable = true;
  # programs.thunar.plugins = with pkgs.xfce; [
  #   thunar-archive-plugin
  #   thunar-volman
  # ];

  services.gnome.gnome-keyring.enable = true;
  programs.seahorse.enable = true;

  programs.steam.enable = true;
  environment.systemPackages = with pkgs; [
    alacritty
    brave
    firefox
    gimp
    helvum
    makemkv
    obs-studio
    qbittorrent
    pcmanfm
    spotify
    ungoogled-chromium
    webcord
    wezterm
    vlc
  ];
}
