{
  pkgs,
  config,
  ...
}: let
  linuxPackages =
    if pkgs.stdenv.isLinux
    then
      with pkgs; [
        distrobox
        vscode.fhs
        android-tools
        claude-code
      ]
    else [];

  linuxGitConfig =
    if pkgs.stdenv.isLinux
    then {
      ".gitconfig.local".text = ''
        [credential]
          helper = "${
          pkgs.git.override {withLibsecret = true;}
        }/bin/git-credential-libsecret";
      '';
    }
    else {};
in {
  programs.direnv.enable = true;

  home.packages = with pkgs;
    [
      git
      gh
      entr
      lazygit
      docker-compose

      alejandra
      nixd
      shfmt

      gnumake

      clang
      clang-tools

      go
      gopls

      black
      (python312.withPackages (ps: with ps; [numpy requests pyserial]))
      pyright
      uv

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

  home.file =
    {
      ".gitconfig" = {
        source = ../../files/gitconfig;
        target =
          if config.isHubspot
          then ".gitconfig.nix"
          else ".gitconfig";
      };

      "aider" = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/dots/files/config/aider/aider.conf.yml";
        target = ".aider.conf.yml";
        recursive = true;
      };
    }
    // linuxGitConfig;
}
