{ config, pkgs, ... }: {
  home.username = "nick";
  home.homeDirectory = "/home/nick";

  home.stateVersion = "23.05";

  programs.home-manager.enable = true;

  programs.neovim.plugins = with pkgs.vimPlugins;
    [
      nvim-treesitter.withAllGrammars
      # codeium-vim
    ];

  home.file.".gitconfig.local".text = ''
    [credential]
      helper = "${
        pkgs.git.override { withLibsecret = true; }
      }/bin/git-credential-libsecret";
  '';
}
