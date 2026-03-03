{
  pkgs,
  config,
  lib,
  ...
}: let
  platformPackages =
    if pkgs.stdenv.isLinux
    then
      with pkgs; [
        cava
        ctpv
        efibootmgr
        libnotify
        playerctl
      ]
    else
      with pkgs; [
      ];
in {
  programs.zsh = {
    enable = false;
    sessionVariables = {
      XDG_CONFIG_HOME = "$HOME/.config";
    };
  };

  programs.yazi = {
    enable = true;
    initLua = ''
      require("full-border"):setup()
      require("git"):setup()
      require("zoxide"):setup {
        update_db = true,
      }

      th.git = th.git or {}

      th.git.modified_sign = ""
      th.git.added_sign = ""
      th.git.untracked_sign = "󱀶"
      th.git.ignored_sign = ""
      th.git.deleted_sign = ""
      th.git.updated_sign = ""
    '';
    settings = {
      plugin.prepend_fetchers = [
        {
          id = "git";
          name = "*";
          run = "git";
        }
        {
          id = "git";
          name = "*/";
          run = "git";
        }
      ];
    };
    keymap = {
      mgr.prepend_keymap = [
        {
          on = ["l"];
          run = "plugin smart-enter";
          desc = "Enter the child directory, or open the file";
        }
        {
          on = ["F"];
          run = "plugin smart-filter";
          desc = "Smart filter";
        }
        {
          on = ["c" "m"];
          run = "plugin chmod";
          desc = "Chmod on selected files";
        }
        {
          on = ["e"];
          run = ''shell -- tmux_nvim "$0"'';
          desc = "Edit file in nvim";
        }
        {
          on = ["c" "b"];
          run =
            if pkgs.stdenv.isLinux
            then ''shell "printf '\\033]52;c;%s\\a' \"$(base64 < \"$0\")\" > /dev/tty"''
            else ''shell "osascript -e \"set the clipboard to POSIX file \\\"$0\\\"\" --" "$@"'';
          desc = "Copy file contents to clipboard (OSC 52)";
        }
      ];
    };
    plugins = with pkgs.yaziPlugins; {
      chmod = chmod;
      full-border = full-border;
      git = git;
      smart-enter = smart-enter;
      smart-filter = smart-filter;
    };
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = "$character$directory$git_branch$git_status";
      right_format = "$nix_shell$cmd_duration$time";

      directory = {
        style = "cyan";
      };

      git_branch = {
        format = "[$symbol$branch(:$remote_branch)]($style) ";
      };

      cmd_duration = {
        min_time = 3000;
        format = "[$duration]($style) ";
      };

      time = {
        disabled = false;
        format = "[$time]($style)";
        style = "blue";
      };

      nix_shell = {
        format = "[$symbol$state]($style) ";
        symbol = " ";
      };
    };
  };

  home.sessionVariables = {NIX_SHELL_PRESERVE_PROMPT = 1;};
  home.packages = with pkgs;
    [
      age
      sops
      bat
      chntpw
      cmatrix
      curl
      delta
      eza
      fastfetch
      ffmpeg
      fzf
      jq
      libsecret
      pipes
      p7zip
      pulsemixer
      ripgrep
      tlrc
      vim
      wget
      xdg-utils
      zoxide
      zellij
    ]
    ++ platformPackages;

  home.file =
    {
      "bin/global" = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/dots/files/local/bin/global";
        target = ".local/bin/global";
        recursive = true;
      };

      "aichat" = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/dots/files/config/aichat/config.yaml";
        target = ".config/aichat/config.yaml";
      };

      "lazygit/config.yml" = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/dots/files/config/lazygit/config.yml";
        target = ".config/lazygit/config.yml";
      };
      "lazygit/tmuxconfig.yml" = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/dots/files/config/lazygit/tmuxconfig.yml";
        target = ".config/lazygit/tmuxconfig.yml";
      };

      ".zshrc" = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/dots/files/zshrc";
        target =
          if config.isHubspot
          then ".zshrc.nix"
          else ".zshrc";
      };
      ".zshrc.generated" = {
        text =
          "#!/usr/bin/env bash\n\n"
          + (
            if pkgs.stdenv.isLinux
            then ''
              if [ -d ~/.venv ]; then
                source /home/nick/.venv/bin/activate
              fi

              alias -- nr='sudo nixos-rebuild switch --flake ~/.config/dots'
            ''
            else ''
              alias -- nr='sudo darwin-rebuild switch --flake ~/.config/dots'
              alias -- finder='open .'
            ''
          )
          + lib.optionalString config.isHubspot ''
            alias -- br='NODE_ARGS="--max_old_space_size=8192" bend reactor serve --UNSUPPORTED_LOCAL_DEV_SETTING bend-webpack.enableFastRefresh --UNSUPPORTED_LOCAL_DEV_SETTING bend-webpack.useWebpack5 --UNSUPPORTED_LOCAL_DEV_SETTING bend-webpack.devtool=eval-source-map $@ --ts-watch --update --enable-tools --run-tests'
          '';
        target = ".zshrc.generated";
      };
      "nvm.plugin.zsh" = {
        source = ../../files/config/zsh/nvm.plugin.zsh;
        target = ".config/zsh/nvm.plugin.zsh";
      };

      "zsh-autosuggestions" = {
        source = builtins.fetchGit {
          url = "https://github.com/zsh-users/zsh-autosuggestions.git";
          ref = "master";
          rev = "c3d4e576c9c86eac62884bd47c01f6faed043fc5";
        };
        target = ".config/zsh/plugins/zsh-autosuggestions";
      };
      "zsh-syntax-highlighting" = {
        source = builtins.fetchGit {
          url = "https://github.com/zsh-users/zsh-syntax-highlighting.git";
          ref = "master";
          rev = "e0165eaa730dd0fa321a6a6de74f092fe87630b0";
        };
        target = ".config/zsh/plugins/zsh-syntax-highlighting";
      };
      "zsh-vim" = {
        source = builtins.fetchGit {
          url = "https://github.com/zap-zsh/vim.git";
          ref = "master";
          rev = "46284178bcad362db40509e1db058fe78844d113";
        };
        target = ".config/zsh/plugins/vim";
      };

      "fastfetch" = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/dots/files/config/fastfetch/config.jsonc";
        target = ".config/fastfetch/config.jsonc";
      };
    }
;

  home.activation = {
    download-whisper-model = lib.hm.dag.entryAfter ["writeBoundary"] ''
      MODEL_PATH="${config.home.homeDirectory}/models"
      MODEL_FILE="$MODEL_PATH/ggml-large-v3-turbo"

      if [ ! -f "$MODEL_FILE" ]; then
        echo "Whisper model not found, downloading..."
        mkdir -p "$MODEL_PATH"

        cd /tmp
        # Download the script first, then execute it with the proper path to curl
        ${pkgs.curl}/bin/curl -s https://raw.githubusercontent.com/ggerganov/whisper.cpp/master/models/download-ggml-model.sh > ./download-model.sh
        PATH="${pkgs.curl}/bin:$PATH" ${pkgs.bash}/bin/bash ./download-model.sh large-v3-turbo

        # Move the downloaded model to the correct location if it's not already there
        echo $(pwd)
        if [ -f "./ggml-large-v3-turbo.bin" ] && [ ! -f "$MODEL_FILE" ]; then
          echo "Moving model to $MODEL_FILE"
          mv "./ggml-large-v3-turbo.bin" "$MODEL_FILE"
        fi
      fi
    '';

    # clone-notes-repo = lib.hm.dag.entryAfter ["writeBoundary"] ''
    #   NOTES_PATH="${config.home.homeDirectory}/notes"
    #
    #   if [ ! -d "$NOTES_PATH" ]; then
    #     echo "Notes repository not found, cloning..."
    #     # Ensure SSH agent is available
    #     if [ -S "$SSH_AUTH_SOCK" ]; then
    #       # Use the full path to git and explicitly set GIT_SSH_COMMAND
    #       GIT_SSH_COMMAND="${pkgs.openssh}/bin/ssh" \
    #         ${pkgs.git}/bin/git clone git@github.com:NickHackford/notes.git "$NOTES_PATH"
    #     else
    #       echo "SSH agent not available, falling back to HTTPS"
    #       ${pkgs.git}/bin/git clone https://github.com/NickHackford/notes.git "$NOTES_PATH"
    #     fi
    #   fi
    # '';
  };
}
