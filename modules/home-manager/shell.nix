{
  pkgs,
  config,
  lib,
  inputs,
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
  zshAliases =
    if pkgs.stdenv.isLinux
    then {
      nr = "sudo nixos-rebuild switch --flake ~/.config/dots";
    }
    else {
      nr = "darwin-rebuild switch --flake ~/.config/dots";
      finder = "open .";
    };
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
    enable = true;
    sessionVariables = {
      XDG_CONFIG_HOME = "$HOME/.config";
    };
    shellAliases =
      {
        ng = "sudo nix-env -p /nix/var/nix/profiles/system --delete-generations old && nix-collect-garbage -d";

        meraxes = "ssh nick@192.168.86.13";
        mushu = "ssh nick@192.168.86.31";
        sindy = "ssh nick@192.168.86.51";

        vi = "nvim";
        ls = "exa";
        ll = "exa -l";
        la = "exa -la";
        cat = "bat";
      }
      // zshAliases;
    initExtra = ''
      ${builtins.readFile ../../files/zshrc}
    '';
    envExtra = ''
      if [ -f ~/.zshenv.local ]; then
        source ~/.zshenv.local
      fi
    '';
  };

  imports = [
    (inputs.nix-yazi-plugins.legacyPackages.x86_64-linux.homeManagerModules.default)
  ];
  programs.yazi = {
    enable = true;
    initLua = lib.mkOrder 500 ''
      THEME.git = THEME.git or {}

      THEME.git.modified_sign = ""
      THEME.git.added_sign = ""
      THEME.git.untracked_sign = "󱀶"
      THEME.git.ignored_sign = ""
      THEME.git.deleted_sign = ""
      THEME.git.updated_sign = ""
    '';
    yaziPlugins = {
      enable = true;
      plugins = {
        chmod.enable = true;
        full-border.enable = true;
        git.enable = true;
        smart-enter.enable = true;
        smart-filter.enable = true;
      };
    };
  };

  home.sessionVariables = {NIX_SHELL_PRESERVE_PROMPT = 1;};
  home.packages = with pkgs;
    [
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

      "mcp.json" = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/dots/files/config/mcp.json";
        target = ".config/mcp.json";
      };

      "lazygit" = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/dots/files/config/lazygit/config.yml";
        target = ".config/lazygit/config.yml";
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
