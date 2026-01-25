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
        # Color with ANSI palette
        %hidden thm_bg="default"
        %hidden thm_black="${config.theme.colors.default.black}"
        %hidden thm_yellow="${config.theme.colors.default.yellow}"
        %hidden thm_blue="${config.theme.colors.extended.blue1}"
        %hidden thm_pink="${config.theme.colors.default.magenta}"
        %hidden thm_white="${config.theme.colors.default.white}"
        %hidden thm_grey="${config.theme.colors.cursor}"
        %hidden thm_orange="${config.theme.colors.indexed.orange}"

        %hidden LEFT=
        %hidden RIGHT=

        set -g mode-style "fg=$thm_black,bg=$thm_white"
        set -g message-style "fg=$thm_yellow,bg=$thm_bg"
        set -g message-command-style "fg=$thm_pink,bg=$thm_bg"
        set -g pane-border-indicators "colour"
        set -g pane-border-style "fg=$thm_black"
        set -g pane-active-border-style "fg=$thm_blue"
        set -g status "on"
        set -g status-justify "left"
        set -g status-style "fg=$thm_white,bg=$thm_bg"
        set -g status-left-length "100"
        set -g status-right-length "100"
        set -g status-left-style NONE
        set -g status-right-style NONE

        set -g status-left "#[bg=$thm_bg,bold]#{?client_prefix,#[fg=$thm_orange],#[fg=$thm_blue]} #[fg=$thm_blue]#S $LEFT"
        set -g status-right "#[bg=$thm_bg,fg=$thm_orange]#h #[fg=$thm_blue]%y-%m-%d $RIGHT %H:%M:%S "
        setw -g window-status-activity-style "underscore,fg=$thm_grey,bg=$thm_black"
        setw -g window-status-separator ""
        setw -g window-status-format "#[fg=$thm_grey,bg=$thm_bg] #I #F #W $LEFT"
        setw -g window-status-current-format "#[fg=$thm_white,bg=$thm_bg,bold] #I #F #[underscore]#W#[fg=$thm_white,bg=$thm_bg,nobold,nounderscore,noitalics] $LEFT"
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
