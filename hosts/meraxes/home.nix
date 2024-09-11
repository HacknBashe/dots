{
  config,
  pkgs,
  lib,
  ...
}: {
  home.username = "nick";
  home.homeDirectory = "/home/nick";

  home.stateVersion = "23.05";

  programs.home-manager.enable = true;
  home.sessionVariables = {NIX_SHELL_PRESERVE_PROMPT = 1;};

  gtk.enable = true;
  gtk.iconTheme.package = pkgs.colloid-icon-theme.override {
    schemeVariants = ["nord"];
    colorVariants = ["teal"];
  };
  gtk.iconTheme.name = "Colloid-teal-nord-dark";

  programs = {
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
        };
        colors = {
          primary = {
            background = config.theme.colors.background;
            foreground = config.theme.colors.foreground;
          };
          cursor = {
            text = config.theme.colors.text;
            cursor = config.theme.colors.cursor;
          };
          normal = config.theme.colors.default;
          bright = config.theme.colors.bright;
          dim = config.theme.colors.default;
          indexed_colors = [
            {
              index = 16;
              color = config.theme.colors.indexed.one;
            }
            {
              index = 17;
              color = config.theme.colors.indexed.two;
            }
          ];
        };
      };
    };
  };

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
    "cava" = {
      text = ''
        [color]
        gradient = 1
        gradient_count = 7
        gradient_color_1 = '${config.theme.colors.default.magenta}'
        gradient_color_2 = '${config.theme.colors.default.blue}'
        gradient_color_3 = '${config.theme.colors.default.cyan}'
        gradient_color_4 = '${config.theme.colors.default.green}'
        gradient_color_5 = '${config.theme.colors.default.yellow}'
        gradient_color_6 = '${config.theme.colors.indexed.one}'
        gradient_color_7 = '${config.theme.colors.indexed.two}'
      '';
      target = ".config/cava/config";
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
        %hidden thm_black="${config.theme.colors.default.black}"
        %hidden thm_yellow="${config.theme.colors.default.yellow}"
        %hidden thm_blue="${config.theme.colors.default.blue}"
        %hidden thm_pink="${config.theme.colors.default.magenta}"
        %hidden thm_white="${config.theme.colors.default.white}"
        %hidden thm_grey="${config.theme.colors.bright.black}"
        %hidden thm_orange="${config.theme.colors.indexed.one}"

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

    "wezterm" = {
      source = ../../files/config/wezterm/wezterm.lua;
      target = ".config/wezterm/wezterm.lua";
    };

    "lf" = {
      source = ../../files/config/lf;
      target = ".config/lf";
      recursive = true;
    };
  };
}
