{ config, pkgs, ... }: {
  virtualisation.docker.enable = true;

  environment.systemPackages = with pkgs; [
    android-tools
    cargo
    conda
    direnv
    distrobox
    dos2unix
    gcc
    git
    gnumake
    go
    lua-language-server
    nixfmt
    (python311.withPackages (ps: with ps; [ requests pyserial ]))
    rustc
    rustup
    nodejs_21
    shfmt
    stylua
    yarn
    yarn2nix
  ];
}
