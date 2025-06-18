{
  pkgs,
  config,
  lib,
  ...
}: let
  linuxPackages =
    if pkgs.stdenv.isLinux
    then
      with pkgs; [
        cava
        ctpv
        efibootmgr
        playerctl
      ]
    else [];
  hubspotFiles =
    if config.isHubspot
    then {
      ".ssh/custom_ssh_config" = {
        source = ../../files/config/ssh/config;
        target = ".ssh/custom_ssh_config";
      };
    }
    else {
      ".ssh/config" = {
        source = ../../files/config/ssh/config;
        target = ".ssh/config";
      };
    };
in {
  programs.zsh = {
    enable = !config.isHubspot;
    sessionVariables = {
      XDG_CONFIG_HOME = "$HOME/.config";
    };
  };

  programs.yazi = {
    enable = true;
    initLua = ''
      require("git"):setup()
      require("full-border"):setup()

      th.git = th.git or {}

      th.git.modified_sign = ""
      th.git.added_sign = ""
      th.git.untracked_sign = "󱀶"
      th.git.ignored_sign = ""
      th.git.deleted_sign = ""
      th.git.updated_sign = ""
    '';
    keymap = {
      manager.prepend_keymap = [
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

  home.sessionVariables = {NIX_SHELL_PRESERVE_PROMPT = 1;};
  home.packages = with pkgs;
    [
      aichat
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
      openai-whisper
      openai-whisper-cpp
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
    ++ linuxPackages;

  home.file =
    {
      "bin" = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/dots/files/local/bin";
        target = ".local/bin";
        recursive = true;
      };

      "aichat" = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/dots/files/config/aichat/config.yaml";
        target = ".config/aichat/config.yaml";
      };

      "mcp.json" = let
        # Hardcoded secrets for now (will be gitignored)
        secrets = {
          GITHUB_PERSONAL_ACCESS_TOKEN = "";
          BRAVE_API_KEY = "";
        };

        commonMcpServers = {
        };

        envSpecificMcpServers =
          if config.isHubspot
          then {
            "devex-mcp-server" = {
              command = "devex-mcp-server";
              args = [];
            };
            "mcp-bend" = {
              command = "mcp-bend";
              args = [
                "--use-cwd"
                "--filter"
                "list-packages"
                "--filter"
                "package-get-tests-results"
                "--filter"
                "package-ts-get-errors"
              ];
              env = {
                MCP_METRICS_ORIGIN = "claude_code";
              };
              type = "stdio";
            };
          }
          else {
            "git" = {
              command = "uv";
              args = ["run" "mcp-server-git"];
            };
            "github" = {
              command = "npx";
              args = ["-y" "@modelcontextprotocol/server-github"];
              env = {
                GITHUB_PERSONAL_ACCESS_TOKEN = secrets.GITHUB_PERSONAL_ACCESS_TOKEN;
              };
            };
            "brave-search" = {
              disabled = false;
              command = "/opt/homebrew/bin/npx";
              args = ["-y" "@modelcontextprotocol/server-brave-search"];
              env = {
                BRAVE_API_KEY = secrets.BRAVE_API_KEY;
              };
            };
          };

        mcpServers = commonMcpServers // envSpecificMcpServers;
      in {
        text = builtins.toJSON {
          mcpServers = mcpServers;
        };
        target = ".config/mcp.json";
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
              alias -- ghe='GH_HOST=git.hubteam.com gh'

            ~/.hubspot/shellrc
          '';
        target = ".zshrc.generated";
      };
      "nvm.plugin.zsh" = {
        source = ../../files/config/zsh/nvm.plugin.zsh;
        target = ".config/zsh/nvm.plugin.zsh";
      };
      ".p10l.zsh" = {
        source = ../../files/config/zsh/.p10k.zsh;
        target = ".config/zsh/.p10k.zsh";
      };
      "powerlevel10k" = {
        source = builtins.fetchGit {
          url = "https://github.com/romkatv/powerlevel10k.git";
          ref = "master";
          rev = "bd0fa8a08f62a6e49f8a2ef47f5103fa840d2198";
        };
        target = ".config/zsh/plugins/powerlevel10k";
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
        source = ../../files/config/fastfetch/config.jsonc;
        target = ".config/fastfetch/config.jsonc";
      };
    }
    // hubspotFiles;

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

    clone-notes-repo = lib.hm.dag.entryAfter ["writeBoundary"] ''
      NOTES_PATH="${config.home.homeDirectory}/notes"

      if [ ! -d "$NOTES_PATH" ]; then
        echo "Notes repository not found, cloning..."
        # Ensure SSH agent is available
        if [ -S "$SSH_AUTH_SOCK" ]; then
          # Use the full path to git and explicitly set GIT_SSH_COMMAND
          GIT_SSH_COMMAND="${pkgs.openssh}/bin/ssh" \
            ${pkgs.git}/bin/git clone git@github.com:NickHackford/notes.git "$NOTES_PATH"
        else
          echo "SSH agent not available, falling back to HTTPS"
          ${pkgs.git}/bin/git clone https://github.com/NickHackford/notes.git "$NOTES_PATH"
        fi
      fi
    '';
  };
}
