{ config, pkgs, ... }: {
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
  environment.shells = with pkgs; [ zsh ];

  # TODO: Get home dir in su
  security.sudo.configFile = ''
    Defaults !always_set_home, !set_home
    Defaults env_keep+=HOME
  '';

  environment.systemPackages = with pkgs; [
    btop
    cava
    chntpw
    curl
    ctpv
    efibootmgr
    fzf
    jq
    libsecret
    lf
    neofetch
    neovim
    p7zip
    pulsemixer
    playerctl
    ripgrep
    wget
    vim
  ];
}
