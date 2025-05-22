{
  config,
  pkgs,
  ...
}: let
  # Hubspot plugins
  bend-nvim = pkgs.vimUtils.buildVimPlugin {
    name = "bend-nvim";
    src = builtins.fetchGit {
      url = "git@git.hubteam.com:HubSpot/bend.nvim.git";
      rev = "c677616a38ed3a444861e8aebf1c27664a099acb";
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
      rev = "97636b902ac20c665b0b3d9d5b2c62c16676e136";
      hash = "sha256-LRiC1daJ9gf/tVphdNOxxHuxAjcXsHZKuwRc4V0WOyM=";
    };
    doCheck = false;
  };
  mcp-hub = pkgs.vimUtils.buildVimPlugin {
    name = "mcp-hub";
    src = pkgs.fetchFromGitHub {
      owner = "ravitemer";
      repo = "mcphub.nvim";
      rev = "0755da600727746f1a315d81f16f73f4203862b0";
      hash = "sha256-jQMaACXXAXH9ocQdTjD46OooEZq/EJyBnyLDwvEX6Vo=";
    };
    doCheck = false;
  };

  hubspotPlugins =
    if config.isHubspot
    then [
      bend-nvim
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
        mcp-hub

        # nvim-dap
        # nvim-dap-ui

        # UI Enhancements
        # vim-fugitive
        neogit
        octo-nvim
        gitsigns-nvim
        mini-nvim
        trouble-nvim

        # Navigation
        harpoon2
        telescope-fzf-native-nvim
        telescope-nvim
        telescope-undo-nvim
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
        sniprun
        vim-sleuth
        vim-table-mode
        vim-tmux-navigator
        better-vim-tmux-resizer
        vim-visual-multi
      ]
      ++ hubspotPlugins;
  };

  home.file = {
    "nvim" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/dots/files/config/nvim";
      target = ".config/nvim";
      recursive = true;
    };
  };
}
