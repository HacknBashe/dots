{ config, pkgs, ... }: {
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
  environment.shells = with pkgs; [ zsh ];

  security.sudo.configFile = ''
    Defaults !always_set_home, !set_home
    Defaults env_keep+=HOME
  '';

  fonts.packages = with pkgs;
    [ (pkgs.nerdfonts.override { fonts = [ "SourceCodePro" ]; }) ];

  environment.systemPackages = with pkgs; [
    btop
    cava
    chntpw
    ctpv
    curl
    efibootmgr
    fzf
    jq
    lf
    libsecret
    neovim
    p7zip
    playerctl
    pulsemixer
    ripgrep
    tmux
    vim
    wget
  ];
}
