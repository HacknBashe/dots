{
  config,
  pkgs,
  ...
}: let
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
  yazi-nvim = pkgs.vimUtils.buildVimPlugin {
    name = "yazi-nvim";
    src = pkgs.fetchFromGitHub {
      owner = "mikavilpas";
      repo = "yazi.nvim";
      rev = "a4e9d2ce9e88dcc146ac621cbb2373e8a5e765c3";
      hash = "sha256-dQ+KFbFtm3XflQl7optMfceR8F3dtF+11Ly6AGSUtkI=";
    };
  };
  asset-bender-nvim = pkgs.vimUtils.buildVimPlugin {
    name = "asset-bender-nvim";
    src = pkgs.fetchFromGitHub {
      owner = "NickHackford";
      repo = "asset-bender.nvim";
      rev = "1facdfe6fc07f64b7d18f285e16e7ef64d04ab9e";
      hash = "sha256-JXTMKAbMHXsPR441r3ylvn5or/0YriWzowl5OVy239s=";
    };
  };
  plugin-utils-nvim = pkgs.vimUtils.buildVimPlugin {
    name = "plugin-utils-nvim";
    src = pkgs.fetchFromGitHub {
      owner = "bobrown101";
      repo = "plugin-utils.nvim";
      rev = "c4a755f9df40f3e91205a87830d7eba1ac7f8c73";
      hash = "sha256-oiGWlyt9+zN7ReQtdtVqFHVeaoypg6vFNOwSr9d3I2Y=";
    };
  };

  hubspotPlugins =
    if config.isHubspot
    then [
      plugin-utils-nvim
      asset-bender-nvim
    ]
    else [];
in {
  programs.neovim = {
    enable = true;

    extraLuaPackages = luaPkgs: with luaPkgs; [luasocket];
    plugins = with pkgs.vimPlugins;
      [
        tokyonight-nvim
        nightfox-nvim
        kanagawa-nvim
        nvim-notify
        nvim-web-devicons

        # nvim-dap
        # nvim-dap-ui

        nvim-lspconfig
        cmp-nvim-lsp
        luasnip
        cmp_luasnip
        #codeium-nvim
        copilot-lua
        CopilotChat-nvim
        copilot-cmp
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
        markdown-preview-nvim
        render-markdown-nvim

        nvim-tree-lua
        nvim-treesitter.withAllGrammars

        nvim-treesitter-context

        obsidian-nvim
        oil-nvim
        playground
        sniprun
        telescope-fzf-native-nvim
        telescope-nvim
        trouble-nvim

        vim-closetag
        vim-commentary
        nvim-ts-context-commentstring
        vim-fugitive
        vim-markdown-toc
        vim-sandwich
        vim-table-mode
        vim-tmux-navigator
        better-vim-tmux-resizer
        vim-visual-multi
        which-key-nvim
        yazi-nvim
      ]
      ++ hubspotPlugins;
    extraLuaConfig = ''
      require('core.nix-init')
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
  };
}
