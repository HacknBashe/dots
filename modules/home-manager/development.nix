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
      opencode

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
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/dots/files/gitconfig";
        target =
          if config.isHubspot
          then ".gitconfig.nix"
          else ".gitconfig";
      };

      "claude/commands" = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/dots/files/config/claude/commands";
        target = ".claude/commands/nix";
        recursive = true;
      };
      "claude/agents" = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/dots/files/config/claude/agents";
        target = ".claude/agents/nix";
        recursive = true;
      };
    }
    // linuxGitConfig;
}
