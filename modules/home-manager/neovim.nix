{
  config,
  pkgs,
  ...
}: let
  # Hubspot plugins
  asset-bender-nvim = pkgs.vimUtils.buildVimPlugin {
    name = "asset-bender-nvim";
    src = pkgs.fetchFromGitHub {
      owner = "bobrown101";
      repo = "asset-bender.nvim";
      rev = "1d715902478cc8f70483ee2f87a1a58a49ebc10f";
      hash = "sha256-JXTMKAbMHXsPR441r3ylvn5or/0YriWzowl5OVy239s=";
    };
    doCheck = false;
  };
  plugin-utils-nvim = pkgs.vimUtils.buildVimPlugin {
    name = "plugin-utils-nvim";
    src = pkgs.fetchFromGitHub {
      owner = "bobrown101";
      repo = "plugin-utils.nvim";
      rev = "c4a755f9df40f3e91205a87830d7eba1ac7f8c73";
      hash = "sha256-oiGWlyt9+zN7ReQtdtVqFHVeaoypg6vFNOwSr9d3I2Y=";
    };
    doCheck = false;
  };
  # Not packaged
  better-vim-tmux-resizer = pkgs.vimUtils.buildVimPlugin {
    name = "better-vim-tmux-resizer";
    src = pkgs.fetchFromGitHub {
      owner = "RyanMillerC";
      repo = "better-vim-tmux-resizer";
      rev = "a791fe5b4433ac43a4dad921e94b7b5f88751048";
      hash = "sha256-1uHcQQUnViktDBZt+aytlBF1ZG+/Ifv5VVoKSyM9ML0=";
    };
  };
  code-companion = pkgs.vimUtils.buildVimPlugin {
    name = "code-companion";
    src = pkgs.fetchFromGitHub {
      owner = "olimorris";
      repo = "codecompanion.nvim";
      rev = "f1a5f7b6adee6762b8c174f5aabe3e139ad583d0";
      hash = "sha256-ABD4yL/gFbYXe565i0j+H88FCeI4cArl0lIEKlRAGjc=";
    };
    doCheck = false;
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
        # Theming
        tokyonight-nvim
        nightfox-nvim
        kanagawa-nvim

        # LSP and Autocompletion
        nvim-cmp
        nvim-lspconfig
        cmp-nvim-lsp
        lspkind-nvim
        luasnip
        cmp_luasnip
        #codeium-nvim
        code-companion
        copilot-lua
        copilot-cmp
        # nvim-dap
        # nvim-dap-ui

        # UI Enhancements
        vim-fugitive
        mini-nvim
        trouble-nvim

        # Navigation
        harpoon2
        telescope-fzf-native-nvim
        telescope-nvim
        yazi-nvim

        # Markdown and Writing
        markdown-preview-nvim
        render-markdown-nvim
        obsidian-nvim
        vim-markdown-toc

        # Treesitter and Syntax
        nvim-treesitter.withAllGrammars
        nvim-treesitter-context
        playground
        vim-closetag
        nvim-ts-context-commentstring

        # Utilities
        formatter-nvim
        vim-hexokinase
        oil-nvim
        sniprun
        # vim-sandwich
        vim-table-mode
        vim-tmux-navigator
        better-vim-tmux-resizer
        vim-visual-multi
      ]
      ++ hubspotPlugins;
  };

  home.file = {
    "nvim" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.homeDirPath}.config/dots/files/config/nvim";
      target = ".config/nvim";
      recursive = true;
    };
  };
}
