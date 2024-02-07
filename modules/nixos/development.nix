{ config, pkgs, ... }: {
  virtualisation.docker.enable = true;

  environment.systemPackages = with pkgs; [
    android-tools
    direnv
    distrobox
    git
    shfmt

    nixfmt
    nil
    
    gcc
    gnumake

    go

    conda
    (python311.withPackages (ps: with ps; [ requests pyserial ]))

    cargo
    rustc
    rustup

    gradle
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
