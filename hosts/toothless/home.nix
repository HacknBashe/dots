{
  config,
  pkgs,
  lib,
  ...
}: let
  background = "#1a1b26";
  foreground = "#c0caf5";
  cursor = "#c0caf5";
  text = "#1a1b26";
  default = {
    black = "#15161e";
    red = "#f7768e";
    green = "#9ece6a";
    yellow = "#e0af68";
    blue = "#7aa2f7";
    magenta = "#bb9af7";
    cyan = "#7dcfff";
    white = "#a9b1d6";
  };
  bright = {
    black = "#414868";
    red = "#f7768e";
    green = "#9ece6a";
    yellow = "#e0af68";
    blue = "#7aa2f7";
    magenta = "#bb9af7";
    cyan = "#7dcfff";
    white = "#c0caf5";
  };
  indexed = {
    one = "#ff9e64";
    two = "#db4b4b";
  };
in {
  home.username = "nick";
  home.homeDirectory = "/Users/nick";

  home.stateVersion = "23.11"; # Please read the comment before changing.

  nix.package = pkgs.nix;
  nix.settings.experimental-features = ["nix-command" "flakes"];
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
            background = background;
            foreground = foreground;
          };
          cursor = {
            text = text;
            cursor = cursor;
          };
          normal = default;
          bright = bright;
          dim = default;
          indexed_colors = [
            {
              index = 16;
              color = indexed.one;
            }
            {
              index = 17;
              color = indexed.two;
            }
          ];
        };
      };
    };
  };

  imports = [
    ../../modules/home-manager/neovim.nix
    ../../modules/home-manager/btop.nix
  ];

  home.sessionVariables = {NIX_SHELL_PRESERVE_PROMPT = 1;};

  home.packages = with pkgs; [
    (pkgs.nerdfonts.override {fonts = ["SourceCodePro"];})

    bat
    btop
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
    tmux
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

    "tmux" = {
      source = ../../files/config/tmux/tmux.conf;
      target = ".config/tmux/tmux.conf";
    };
    "tmux.theme" = {
      target = ".config/tmux/theme.tmux";
      text = ''
        #!/usr/bin/env bash
        # Color with ANSI palette
        %hidden thm_bg="default"
        %hidden thm_black="${default.black}"
        %hidden thm_yellow="${default.yellow}"
        %hidden thm_blue="${default.blue}"
        %hidden thm_pink="${default.magenta}"
        %hidden thm_white="${default.white}"
        %hidden thm_grey="${cursor}"
        %hidden thm_orange="${indexed.one}"

        %hidden LEFT=
        %hidden RIGHT=

        set -g mode-style "fg=$thm_black,bg=$thm_white"
        set -g message-style "fg=$thm_yellow,bg=$thm_bg"
        set -g message-command-style "fg=$thm_pink,bg=$thm_bg"
        set -g pane-border-indicators "colour"
        set -g pane-border-style "fg=$thm_black"
        set -g pane-active-border-style "fg=$thm_blue"
        set -g status "on"
        set -g status-justify "left"
        set -g status-style "fg=$thm_white,bg=$thm_bg"
        set -g status-left-length "100"
        set -g status-right-length "100"
        set -g status-left-style NONE
        set -g status-right-style NONE

        set -g status-left "#[bg=$thm_bg,bold]#{?client_prefix,#[fg=$thm_orange],#[fg=$thm_blue]} #[fg=$thm_blue]#S $LEFT"
        set -g status-right "#[bg=$thm_bg,fg=$thm_blue]%y-%m-%d $RIGHT %H:%M:%S "
        setw -g window-status-activity-style "underscore,fg=$thm_grey,bg=$thm_black"
        setw -g window-status-separator ""
        setw -g window-status-format "#[fg=$thm_grey,bg=$thm_bg] #I $LEFT #{b:pane_current_path} #F #W $LEFT"
        setw -g window-status-current-format "#[fg=$thm_white,bg=$thm_bg,bold] #I $LEFT #[underscore]./#{b:pane_current_path}#[nounderscore] #F #[underscore]#W#[fg=$thm_white,bg=$thm_bg,nobold,nounderscore,noitalics] $LEFT"
      '';
    };
    "tpm" = {
      source = builtins.fetchGit {
        url = "https://github.com/tmux-plugins/tpm";
        ref = "master";
        rev = "99469c4a9b1ccf77fade25842dc7bafbc8ce9946";
      };
      target = ".tmux/plugins/tpm";
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
