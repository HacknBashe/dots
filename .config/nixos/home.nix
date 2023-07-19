{ config, pkgs, ... }:
{
    home.username = "nick";
    home.homeDirectory = "/home/nick";

    home.stateVersion = "23.05";

    programs.home-manager.enable = true;
#    programs.neovim.plugins = [
#        pkgs.vimPlugins.codeium-vim
#        pkgs.vimPlugins.nvim-treesitter.withAllGrammars
#    ];
}
