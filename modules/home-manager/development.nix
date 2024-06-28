{
  config,
  pkgs,
  ...
}: {
  programs.direnv.enable = true;

  home.packages = with pkgs; [
    # only our vms
    azure-cli
    bc

    git
    lazygit

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
