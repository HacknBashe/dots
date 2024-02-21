{ config, pkgs, lib, ... }:
with config.lib.stylix.colors.withHashtag; {
  home.username = "nick";
  home.homeDirectory = "/home/nick";

  home.stateVersion = "23.05";

  programs.home-manager.enable = true;
  home.sessionVariables = { NIX_SHELL_PRESERVE_PROMPT = 1; };

  imports = [
    ../../modules/home-manager/neovim.nix
    ../../modules/home-manager/hyprland.nix
  ];

  gtk.enable = true;
  gtk.iconTheme.package = (pkgs.colloid-icon-theme.override {
    schemeVariants = [ "nord" ];
    colorVariants = [ "teal" ];
  });
  gtk.iconTheme.name = "Colloid-teal-nord-dark";

  programs = {
    alacritty = {
      enable = true;
      settings = {
        font.size = lib.mkForce 20.0;
        font.bold.style = lib.mkForce "Regular";
        font.normal.style = lib.mkForce "ExtraLight";
        window = {
          decorations = "full";
          dynamic_padding = true;
          opacity = lib.mkForce 0.9;
        };
      };
    };

    btop = {
      enable = true;
      settings = {
        color_theme = "tokyo-storm";
        theme_background = false;
        rounded_corners = true;
        vim_keys = true;
        background_update = false;
      };
    };
  };

  home.file = {
    "scripts" = {
      source = ../../files/local/scripts;
      target = ".local/scripts";
      recursive = true;
    };

    ".gitconfig" = {
      source = ../../files/gitconfig;
      target = ".gitconfig";
    };
    ".gitconfig.local".text = ''
      [credential]
        helper = "${
          pkgs.git.override { withLibsecret = true; }
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
        gradient_color_1 = '${base0E}'
        gradient_color_2 = '${base0D}'
        gradient_color_3 = '${base0C}'
        gradient_color_4 = '${base0B}'
        gradient_color_5 = '${base0A}'
        gradient_color_6 = '${base09}'
        gradient_color_7 = '${base08}'
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
        %hidden thm_black="${base00}"
        %hidden thm_yellow="${base0A}"
        %hidden thm_blue="${base0D}"
        %hidden thm_pink="${base0E}"
        %hidden thm_white="${base07}"
        %hidden thm_grey="${base04}"
        %hidden thm_orange="${base09}"

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
}
