{ config, pkgs, ... }:
let
  harpoon2 = pkgs.vimUtils.buildVimPlugin {
    name = "harpoon2";
    src = pkgs.fetchFromGitHub {
      owner = "ThePrimeagen";
      repo = "harpoon";
      rev = "7d1aef462a880fcb68419cb63abc50dbdc22d922";
      hash = "sha256-AXWN7HqlnSsmtCK8jK5vqyzHwKJY3eJL6fnjeJhoNMU=";
    };
  };
  # TODO: Remove once updated in nixpkgs
  nvim-treesitter-context-fix = pkgs.vimUtils.buildVimPlugin {
    name = "nvim-treesitter-context";
    src = pkgs.fetchFromGitHub {
      owner = "nvim-treesitter";
      repo = "nvim-treesitter-context";
      rev = "f3ec0d8a1b4e07d7ed2da6b9a9f10864a83c4be4";
      hash = "sha256-93f4YPUwQLkaTGJlK+OGspIFZ8t14iSpFz7+9Akgfc0=";
    };
  };
in {
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
      harpoon2
      lazygit-nvim
      lualine-nvim
      # FIXME Doesn't work for some reason
      markdown-preview-nvim
      nvim-tree-lua
      nvim-treesitter.withAllGrammars
      # TODO disabled because it breaks on format
      nvim-treesitter-context-fix
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
    # TODO: Remove once base16 fixes md highlighting and stylix adds transparency to floats
    extraConfig = ''
      let base16_background_transparent=1 
      source ~/.config/nvim/systembase16.vim
    '';
  };
  home.file = {
    "nvim-settings" = {
      source = ../../files/config/nvim/lua/core;
      target = ".config/nvim/lua/core";
      recursive = true;
    };
    "nvim-plugins" = {
      source = ../../files/config/nvim/lua/plugins;
      target = ".config/nvim/lua/plugins";
      recursive = true;
    };
    "base16" = import ./systembase16.nix { inherit config; };
  };
}
