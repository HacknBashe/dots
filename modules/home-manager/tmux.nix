{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [tmux];

  home.file = {
    "tmux" = {
      target = ".config/tmux/tmux.conf";
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/dots/files/config/tmux/tmux.conf";
    };
    "tmux.theme" = {
      target = ".config/tmux/theme.tmux";
      text = ''
        #!/usr/bin/env bash
        # Theme color definitions (nix-managed, requires rebuild to change)
        # All status bar layout config lives in tmux.conf

        # Export theme colors as server options for use in tmux.conf and scripts
        set -g @thm_bg "default"
        set -g @thm_black "${config.theme.colors.default.black}"
        set -g @thm_yellow "${config.theme.colors.default.yellow}"
        set -g @thm_blue "${config.theme.colors.default.blue}"
        set -g @thm_white "${config.theme.colors.default.white}"
        set -g @thm_grey "${config.theme.colors.indexed.bgStatusline}"
        set -g @thm_dark "${config.theme.colors.extended.bgDark}"
        set -g @thm_orange "${config.theme.colors.indexed.orange}"
        set -g @thm_green "${config.theme.colors.default.green}"
      '';
    };
    "tpm" = {
      source = builtins.fetchGit {
        url = "https://github.com/tmux-plugins/tpm";
        ref = "master";
        rev = "99469c4a9b1ccf77fade25842dc7bafbc8ce9946";
      };
      target = ".tmux/plugins/tpm";
    };
  };
}
