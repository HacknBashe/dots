{
  pkgs,
  config,
  lib,
  ...
}: let
  # Treesitter configuration from neovim-lazy.nix
  treesitterWithGrammars = pkgs.vimPlugins.nvim-treesitter.withAllGrammars;
  treesitter-parsers = pkgs.symlinkJoin {
    name = "treesitter-parsers";
    paths = treesitterWithGrammars.dependencies;
  };

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
        [user]
        name = Nick Hackford
        email = nick.hackford@gmail.com
        signingkey = ~/.ssh/git_signing_key.pub

        [gpg]
        format = ssh

        [commit]
        gpgsign = true

        [credential]
          helper = "${
          pkgs.git.override {withLibsecret = true;}
        }/bin/git-credential-libsecret";
      '';
    }
    else {};
in {
  options.development = {
    enableRust = lib.mkOption {
      description = ''
        Enable Rust development tools (rustc, rustup)
      '';
      type = lib.types.bool;
      default = true;
    };

    enablePython = lib.mkOption {
      description = ''
        Enable Python development tools (python312, pyright, black, uv)
      '';
      type = lib.types.bool;
      default = true;
    };

    enableJava = lib.mkOption {
      description = ''
        Enable Java development tools (temurin, jdt-language-server, gradle, google-java-format)
      '';
      type = lib.types.bool;
      default = true;
    };
  };

  config = {
    programs.direnv.enable = true;

    programs.neovim = {
      enable = true;
      extraLuaPackages = luaPkgs: with luaPkgs; [luasocket];
      plugins = [
        treesitterWithGrammars
      ];
    };

    home.packages = with pkgs;
      [
        # Core development tools (always included)
        git
        gh
        entr
        lazygit
        docker-compose

        # Core neovim plugin dependencies
        gnumake # telescope-fzf-native.nvim build

        # Build tools (also used for native plugin compilation)
        clang
        clang-tools

        # Language servers & formatters (always included for neovim)
        alejandra
        nixd
        shfmt
        lua-language-server
        stylua
        prettierd

        # Lua runtime (for scripting)
        lua

        # Go (always included - needed for hexokinase)
        go
        gopls

        # Node.js (always included - needed for copilot, markdown-preview, opencode)
        nodejs_22
        nodePackages.typescript-language-server
        bun
      ]
      ++ lib.optionals config.development.enableRust [
        rustc
        rustup
      ]
      ++ lib.optionals config.development.enablePython [
        black
        (python312.withPackages (ps: with ps; [numpy requests pyserial]))
        pyright
        uv
      ]
      ++ lib.optionals config.development.enableJava [
        gradle
        temurin-bin-21
        jdt-language-server
        google-java-format
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
          source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/dots/files/config/opencode/commands";
          target = ".claude/commands/nix";
          recursive = true;
        };
        "claude/agents" = {
          source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/dots/files/config/claude/agents";
          target = ".claude/agents/nix";
          recursive = true;
        };

        # Neovim configuration (from neovim-lazy.nix)
        "nvim" = {
          source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/dots/files/config/nvim";
          target = ".config/nvim";
          recursive = true;
        };
        "./.local/share/nvim/nix/nvim-treesitter" = {
          recursive = true;
          source = treesitterWithGrammars;
        };
        "./.local/share/nvim/nix/treesitter-path.lua" = {
          text = ''
            return "${treesitter-parsers}"
          '';
        };
      }
      // linuxGitConfig;
  };
}
