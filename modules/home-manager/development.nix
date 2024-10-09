{
  config,
  pkgs,
  ...
}: let
  linuxPackages =
    if pkgs.stdenv.isLinux
    then
      with pkgs; [
        distrobox
        vscode.fhs
        android-tools

        gcc
      ]
    else [];
in {
  programs.direnv.enable = true;

  home.packages = with pkgs;
    [
      git
      lazygit
      docker-compose

      alejandra
      nil
      shfmt

      gnumake

      go
      gopls

      black
      (python311.withPackages (ps: with ps; [numpy requests pyserial]))
      pyright

      rustc
      rustup

      gradle
      temurin-bin-21
      jdt-language-server
      google-java-format

      lua
      lua-language-server
      stylua

      nodejs_22
      nodePackages.typescript-language-server
      prettierd
      yarn
      yarn2nix
    ]
    ++ linuxPackages;

  home.file = {
    ".gitconfig" = {
      source = ../../files/gitconfig;
      target = ".gitconfig";
    };
    ".gitconfig.local".text = ''
      [credential]
        helper = "${
        pkgs.git.override {withLibsecret = true;}
      }/bin/git-credential-libsecret";
    '';
  };
}
