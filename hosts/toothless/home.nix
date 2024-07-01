{
  config,
  pkgs,
  lib,
  colors,
  ...
}: {
  home.username = "nick";
  home.homeDirectory = "/Users/nick";

  home.stateVersion = "23.11"; # Please read the comment before changing.

  fonts.fontconfig.enable = true;
  programs = {
    home-manager.enable = true;
    alacritty = {
      enable = true;
      settings = {
        font.size = 20.0;
        font.bold.style = lib.mkForce "Regular";
        font.normal.family = "SauceCodePro Nerd Font Mono";
        font.normal.style = lib.mkForce "ExtraLight";
        window = {
          decorations = "none";
          dynamic_padding = true;
          opacity = lib.mkForce 0.9;
        };
        colors = {
          primary = {
            background = colors.background;
            foreground = colors.foreground;
          };
          cursor = {
            text = colors.text;
            cursor = colors.cursor;
          };
          normal = colors.default;
          bright = colors.bright;
          dim = colors.default;
          indexed_colors = [
            {
              index = 16;
              color = colors.indexed.one;
            }
            {
              index = 17;
              color = colors.indexed.two;
            }
          ];
        };
      };
    };
  };

  home.sessionVariables = {NIX_SHELL_PRESERVE_PROMPT = 1;};

  home.packages = with pkgs; [
    (pkgs.nerdfonts.override {fonts = ["SourceCodePro"];})

    bat
    cmatrix
    #ctpv
    curl
    delta
    eza
    fastfetch
    fzf
    jq
    lf
    pipes
    p7zip
    renameutils
    ripgrep
    tlrc
    vim
    wget
    zoxide
    zellij

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
    #conda
    (python311.withPackages (ps: with ps; [numpy requests pyserial]))

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
  ];

  home.file = {
    "bin" = {
      source = ../../files/local/bin;
      target = ".local/bin";
      recursive = true;
    };
    "cht" = {
      source = ../../files/local/share/cht;
      target = ".local/share/cht";
      recursive = true;
    };

    ".amethyst.yml" = {
      source = ../../files/amethyst.yml;
      target = ".amethyst.yml";
    };

    ".gitconfig" = {
      source = ../../files/gitconfig;
      target = ".gitconfig";
    };

    "nvm.plugin.zsh" = {
      source = ../../files/config/zsh/nvm.plugin.zsh;
      target = ".config/zsh/nvm.plugin.zsh";
    };
    ".p10l.zsh" = {
      source = ../../files/config/zsh/.p10k.zsh;
      target = ".config/zsh/.p10k.zsh";
    };
    ".zshrc" = {
      source = ../../files/zshrc;
      target = ".zshrc";
    };
    "powerlevel10k" = {
      source = builtins.fetchGit {
        url = "https://github.com/romkatv/powerlevel10k.git";
        ref = "master";
        rev = "bd0fa8a08f62a6e49f8a2ef47f5103fa840d2198";
      };
      target = ".config/zsh/plugins/powerlevel10k";
    };
    "zsh-autosuggestions" = {
      source = builtins.fetchGit {
        url = "https://github.com/zsh-users/zsh-autosuggestions.git";
        ref = "master";
        rev = "c3d4e576c9c86eac62884bd47c01f6faed043fc5";
      };
      target = ".config/zsh/plugins/zsh-autosuggestions";
    };
    "zsh-syntax-highlighting" = {
      source = builtins.fetchGit {
        url = "https://github.com/zsh-users/zsh-syntax-highlighting.git";
        ref = "master";
        rev = "e0165eaa730dd0fa321a6a6de74f092fe87630b0";
      };
      target = ".config/zsh/plugins/zsh-syntax-highlighting";
    };
    "zsh-vim" = {
      source = builtins.fetchGit {
        url = "https://github.com/zap-zsh/vim.git";
        ref = "master";
        rev = "46284178bcad362db40509e1db058fe78844d113";
      };
      target = ".config/zsh/plugins/vim";
    };

    "fastfetch" = {
      source = ../../files/config/fastfetch/config.jsonc;
      target = ".config/fastfetch/config.jsonc";
    };

    "lf" = {
      source = ../../files/config/lf;
      target = ".config/lf";
      recursive = true;
    };
  };
  home.activation = {
    rsync-home-manager-applications = lib.hm.dag.entryAfter ["writeBoundary"] ''
      rsyncArgs="--archive --checksum --chmod=-w --copy-unsafe-links --delete"
      apps_source="$genProfilePath/home-path/Applications"
      moniker="Home Manager Trampolines"
      app_target_base="${config.home.homeDirectory}/Applications"
      app_target="$app_target_base/$moniker"
      mkdir -p "$app_target"
      ${pkgs.rsync}/bin/rsync $rsyncArgs "$apps_source/" "$app_target"
    '';
  };
}
