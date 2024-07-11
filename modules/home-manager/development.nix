{
  config,
  pkgs,
  ...
}: {
  programs.direnv.enable = true;

  home.packages = with pkgs; [
    vscode.fhs
    android-tools

    distrobox
    docker-compose

    git
    lazygit

    # Nix
    alejandra
    nil
    shfmt

    # C
    gcc
    gnumake

    # Go
    go
    gopls

    # Python
    black
    conda
    (python311.withPackages (ps: with ps; [numpy requests pyserial]))

    # Rust
    # cargo
    rustc
    rustup

    # Java
    gradle
    temurin-bin-21
    jdt-language-server
    google-java-format

    # Lua
    lua
    lua-language-server
    stylua

    # Javascript
    nodejs_22
    nodePackages.typescript-language-server
    prettierd
    yarn
    yarn2nix
    cypress
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
