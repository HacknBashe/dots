{
  pkgs,
  config,
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
      libsecret
      pipes
      p7zip
      pulsemixer
      renameutils
      ripgrep
      tlrc
      wget
      xdg-utils
      zellij
      zoxide
    ]
    ++ linuxPackages;

  programs.adb.enable = true;
  users.users.nick.extraGroups = ["adbusers"];

  services.ollama.enable = true;

  services.cron = {
    enable = true;
    cronFiles = [
      (pkgs.writeText "auto_commit_notes" ''
        0 * * * * ${config.users.users.nick.home}/.local/bin/auto_commit_notes.sh >> ${config.users.users.nick.home}/.auto_commit_notes.log 2>&1
      '')
    ];
  };
}
