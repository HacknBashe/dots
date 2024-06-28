{
  config,
  pkgs,
  ...
}: {
  virtualisation.docker.enable = true;

  programs.direnv.enable = true;

  environment.systemPackages = with pkgs; [
    android-tools
    distrobox
    git
    lazygit
    vscode.fhs
    docker-compose

    alejandra
    nil
    shfmt

    gcc
    gnumake

    go
    gopls

    black
    conda
    (python311.withPackages (ps: with ps; [numpy requests pyserial]))

    cargo
    rustc
    rustup

    gradle
    temurin-bin-21
    jdt-language-server
    google-java-format

    lua
    lua-language-server
    stylua

    nodejs_21
    nodePackages.typescript-language-server
    prettierd
    yarn
    yarn2nix
  ];
}
