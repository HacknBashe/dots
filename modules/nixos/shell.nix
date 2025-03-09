{
  pkgs,
  inputs,
  ...
}: let
  linuxPackages =
    if pkgs.stdenv.isLinux
    then
      with pkgs; [
        cava
        ctpv
        efibootmgr
        playerctl
      ]
    else [];
in {
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
  environment.shells = with pkgs; [zsh];

  fonts.packages = with pkgs; [
    nerd-fonts.sauce-code-pro
  ];

  environment.systemPackages = with pkgs;
    [
      bat
      chntpw
      cmatrix
      curl
      delta
      eza
      fastfetch
      fzf
      jq
      lf
      libsecret
      pipes
      p7zip
      pulsemixer
      renameutils
      ripgrep
      tlrc
      vim
      vitetris
      wget
      xdg-utils
      zellij
      zoxide
    ]
    ++ linuxPackages;
  services.ollama.enable = true;
}
