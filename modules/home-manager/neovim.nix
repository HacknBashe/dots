{ config, pkgs, system, codeium, ... }: {
  nixpkgs.overlays = [ codeium.overlays.${system}.default ];

  programs.neovim = {
    enable = true;
    extraLuaPackages = luaPkgs: with luaPkgs; [ luasocket ];
    plugins = with pkgs.vimPlugins; [
      # nvim-dap
      # nvim-dap-ui

      nvim-lspconfig
      nvim-cmp
      codeium-nvim
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
      nightfox-nvim
      nvim-tree-lua
      nvim-treesitter.withAllGrammars
      # TODO disabled because it breaks on format for some reason
      # nvim-treesitter-context
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
      source = ../../files/.config/nvim/lua/core;
      target = ".config/nvim/lua/core";
      recursive = true;
    };
    "nvim-plugins" = {
      source = ../../files/.config/nvim/lua/plugins;
      target = ".config/nvim/lua/plugins";
      recursive = true;
    };
  };
}
