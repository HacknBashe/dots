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
        # Blocky theme - uses background colors for visual separation
        %hidden thm_bg="default"
        %hidden thm_black="${config.theme.colors.default.black}"
        %hidden thm_yellow="${config.theme.colors.default.yellow}"
        %hidden thm_blue="${config.theme.colors.default.blue}"
        %hidden thm_white="${config.theme.colors.default.white}"
        %hidden thm_grey="${config.theme.colors.indexed.bgStatusline}"
        %hidden thm_dark="${config.theme.colors.extended.bgDark}"
        %hidden thm_orange="${config.theme.colors.indexed.orange}"

        set -g mode-style "fg=$thm_black,bg=$thm_white"
        set -g message-style "fg=$thm_yellow,bg=$thm_bg"
        set -g message-command-style "fg=$thm_yellow,bg=$thm_bg"
        set -g pane-border-indicators "colour"
        set -g pane-border-style "fg=$thm_black"
        set -g pane-active-border-style "fg=$thm_blue"
        set -g status "on"
        set -g status-justify "left"
        set -g status-style "fg=$thm_white,bg=$thm_grey"
        set -g status-left-length "100"
        set -g status-right-length "100"
        set -g status-left-style NONE
        set -g status-right-style NONE

        set -g status-left "#[bg=$thm_dark]#{?client_prefix,#[fg=$thm_orange],#[fg=$thm_blue]} 󰄚#[fg=$thm_blue,bg=$thm_dark] #S #[bg=$thm_grey] "
        set -g status-right "#[fg=$thm_yellow] #h #[fg=$thm_blue,bg=$thm_dark] %y-%m-%d #[fg=$thm_blue]%H:%M "
        setw -g window-status-activity-style "fg=$thm_white,bg=$thm_orange"
        setw -g window-status-separator ""
        setw -g window-status-format "#[fg=$thm_white,bg=$thm_grey] #I #W "
        setw -g window-status-current-format "#[fg=$thm_yellow,bg=$thm_grey] #I #W "
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
