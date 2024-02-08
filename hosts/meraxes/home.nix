{ config, pkgs, system, codeium, ... }: {
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
  gtk.theme.package = pkgs.mojave-gtk-theme;
  gtk.theme.name = "Mojave-Dark-solid";
  gtk.iconTheme.package = (pkgs.colloid-icon-theme.override {
    schemeVariants = [ "nord" ];
    colorVariants = [ "teal" ];
  });
  gtk.iconTheme.name = "Colloid-teal-nord-dark";

  programs.btop = {
    enable = true;
    settings = {
      color_theme = "tokyo-storm";
      theme_background = false;
      rounded_corners = true;
      vim_keys = true;
      background_update = false;
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

    "alacritty" = {
      source = ../../files/config/alacritty/alacritty.toml;
      target = ".config/alacritty/alacritty.toml";
    };

    "tmux" = {
      source = ../../files/config/tmux;
      target = ".config/tmux";
      recursive = true;
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
