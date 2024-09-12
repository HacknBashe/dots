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
