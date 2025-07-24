{
  config,
  pkgs,
  ...
}: let
  # This file was stolen from
  # https://github.com/Kidsan/nixos-config/blob/bfa828714b8f889c362cddbf9799d6ec8056a7b3/home/programs/neovim/default.nix
  treesitterWithGrammars = pkgs.vimPlugins.nvim-treesitter.withAllGrammars;

  treesitter-parsers = pkgs.symlinkJoin {
    name = "treesitter-parsers";
    paths = treesitterWithGrammars.dependencies;
  };
in {
  home.packages = with pkgs; [
    # TODO: NVIM-NIX Move my language devpackages from shell into here?
  ];

  programs.neovim = {
    enable = true;

    extraLuaPackages = luaPkgs: with luaPkgs; [luasocket];
    plugins = [
      treesitterWithGrammars
    ];
  };

  home.file = {
    "nvim" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/dots/files/config/nvim";
      target = ".config/nvim";
      recursive = true;
    };
    # "./.config/nvim/lua/core/treesitter.lua".text = ''
    #   vim.opt.runtimepath:append("${treesitter-parsers}")
    # '';
    # Treesitter is configured as a locally developed module in lazy.nvim
    # we hardcode a symlink here so that we can refer to it in our lazy config
    "./.local/share/nvim/nix/nvim-treesitter" = {
      recursive = true;
      source = treesitterWithGrammars;
    };
  };
}
