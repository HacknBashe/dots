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
  better-vim-tmux-resizer = pkgs.vimUtils.buildVimPlugin {
    name = "better-vim-tmux-resizer";
    src = pkgs.fetchFromGitHub {
      owner = "RyanMillerC";
      repo = "better-vim-tmux-resizer";
      rev = "a791fe5b4433ac43a4dad921e94b7b5f88751048";
      hash = "sha256-1uHcQQUnViktDBZt+aytlBF1ZG+/Ifv5VVoKSyM9ML0=";
    };
  };
  obsidian-nvim = pkgs.vimUtils.buildVimPlugin {
    name = "obsidian-nvim";
    src = pkgs.fetchFromGitHub {
      owner = "epwalsh";
      repo = "obsidian.nvim";
      rev = "ebf4cd26f8c69e6ed025d06dfb4144212817878b";
      hash = "sha256-8JpbqzbAs6fvM3iyyWszBl1LIp1tqNJ4Ngep0EunCRg=";
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
      cmp-nvim-lsp
      luasnip
      cmp_luasnip
      codeium-nvim
      nvim-cmp
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
      nvim-treesitter-context
      obsidian-nvim
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
      better-vim-tmux-resizer
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
    "snippets" = {
      source = ../../files/config/nvim/snippets;
      target = ".config/nvim/snippets";
      recursive = true;
    };
    "base16" = import ./systembase16.nix { inherit config; };
  };
}
