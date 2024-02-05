{ config, pkgs, ... }: {
  virtualisation.docker.enable = true;

  environment.systemPackages = with pkgs; [
    android-tools
    direnv
    distrobox
    git
    nixfmt
    shfmt

    gcc
    gnumake

    go

    conda
    (python311.withPackages (ps: with ps; [ requests pyserial ]))

    cargo
    rustc
    rustup

    temurin-bin-21
    jdt-language-server
    google-java-format

    lua-language-server
    stylua

    nodejs_21
    yarn
    yarn2nix
  ];
}
