{ config, pkgs, system, codeium, ... }: {
  home.username = "nick";
  home.homeDirectory = "/home/nick";

  home.stateVersion = "23.05";

  nixpkgs.overlays = [ codeium.overlays.${system}.default ];

  gtk.enable = true;
  gtk.theme.package = pkgs.adw-gtk3;
  gtk.theme.name = "adw-gtk3-dark";

  programs.home-manager.enable = true;

  programs.neovim = {
    enable = true;
    extraLuaPackages = luaPkgs: with luaPkgs; [ luasocket ];
    plugins = with pkgs.vimPlugins; [
      #  code-runner.lua - not in nixpkgs
      # nvim-dap
      # nvim-dap-ui

      codeium-nvim
      # Working

      nvim-lspconfig
      nvim-cmp
      cmp-nvim-lsp
      luasnip
      lspkind-nvim
      alpha-nvim
      bufferline-nvim
      formatter-nvim
      gitsigns-nvim
      vim-hexokinase
      harpoon
      lualine-nvim
      # FIXME Doesn't work for some reason
      markdown-preview-nvim
      # zbirenbaum/neodim
      nightfox-nvim
      nvim-tree-lua
      nvim-treesitter.withAllGrammars
      nvim-treesitter-context
      playground
      sniprun
      telescope-fzf-native-nvim
      telescope-nvim
      trouble-nvim
      vim-closetag
      vim-commentary
      vim-fugitive
      vim-markdown-toc
      vim-sleuth
      vim-sandwich
      vim-table-mode
      vim-tmux-navigator
      vim-visual-multi
      which-key-nvim
    ];

    extraLuaConfig = ''
      require('core.nix-init')
    '';
  };
  home.file = {
    "nvim-settings" = {
      source = ../../dots/.config/nvim/lua/core;
      target = ".config/nvim/lua/core";
      recursive = true;
    };
    "nvim-plugins" = {
      source = ../../dots/.config/nvim/lua/plugins;
      target = ".config/nvim/lua/plugins";
      recursive = true;
    };
  };

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
    "fonts" = {
      source = ../../dots/.local/share/fonts;
      target = ".local/share/fonts";
      recursive = true;
    };

    "scripts" = {
      source = ../../dots/.local/scripts;
      target = ".local/scripts";
      recursive = true;
    };

    ".gitconfig" = {
      source = ../../dots/.gitconfig;
      target = ".gitconfig";
    };
    ".gitconfig.local".text = ''
      [credential]
        helper = "${
          pkgs.git.override { withLibsecret = true; }
        }/bin/git-credential-libsecret";
    '';

    "nvm.plugin.zsh" = {
      source = ../../dots/.config/zsh/nvm.plugin.zsh;
      target = ".config/zsh/nvm.plugin.zsh";
    };
    ".p10l.zsh" = {
      source = ../../dots/.config/zsh/.p10k.zsh;
      target = ".config/zsh/.p10k.zsh";
    };
    ".zshrc" = {
      source = ../../dots/.zshrc;
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
      source = ../../dots/.config/alacritty/alacritty.toml;
      target = ".config/alacritty/alacritty.toml";
    };

    "tmux" = {
      source = ../../dots/.config/tmux;
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
      source = ../../dots/.config/lf;
      target = ".config/lf";
      recursive = true;
    };

    "neofetch" = {
      source = ../../dots/.config/neofetch/config.conf;
      target = ".config/neofetch/config.conf";
    };

    "hypr" = {
      source = ../../dots/.config/hypr/hyprland.conf;
      target = ".config/hypr/hyprland.conf";
    };
    "hypr/scripts" = {
      source = ../../dots/.config/hypr/scripts;
      target = ".config/hypr/scripts";
      recursive = true;
    };
    "hypr/shaders" = {
      source = ../../dots/.config/hypr/shaders;
      target = ".config/hypr/shaders";
      recursive = true;
    };

    "waybar" = {
      source = ../../dots/.config/waybar;
      target = ".config/waybar";
      recursive = true;
    };
    "waybar/scripts" = {
      source = ../../dots/.config/waybar/scripts;
      target = ".config/waybar/scripts";
      recursive = true;
    };

    "wofi" = {
      source = ../../dots/.config/wofi/style.css;
      target = ".config/wofi/style.css";
    };

    "wlogout" = {
      source = ../../dots/.config/wlogout;
      target = ".config/wlogout";
      recursive = true;
    };
  };
}
