{ config, pkgs, ... }: {
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
  environment.shells = with pkgs; [ zsh ];

  fonts.packages = with pkgs;
    [ (pkgs.nerdfonts.override { fonts = [ "SourceCodePro" ]; }) ];

  # for btop GPU support
  environment.variables = {
    LD_LIBRARY_PATH = "/run/opengl-driver/lib:/run/opengl-driver-32/lib";
  };

  environment.systemPackages = with pkgs; [
    (pkgs.btop.override { cudaSupport = true; })
    cava
    chntpw
    ctpv
    curl
    efibootmgr
    fastfetch
    fzf
    jq
    lf
    libsecret
    neovim
    nvtop
    pipes
    p7zip
    playerctl
    pulsemixer
    ripgrep
    tmux
    vim
    vitetris
    wget
    zoxide
  ];
}
