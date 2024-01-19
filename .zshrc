# zmodload zsh/zprof

#!/bin/bash

if command -v fnm &>/dev/null; then
    eval "$(fnm env --use-on-cd)"
fi

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
# if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#   source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
# fi

# Source plugin submodules
source ~/.config/zsh/plugins/vim/vim.plugin.zsh
source ~/.config/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.config/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/.config/zsh/plugins/powerlevel10k/powerlevel10k.zsh-theme
source ~/.config/zsh/plugins/powerlevel10k/config/p10k-robbyrussell.zsh
source ~/.config/zsh/.p10k.zsh

autoload -U compinit && compinit

# history setup
setopt APPEND_HISTORY
setopt SHARE_HISTORY
HISTFILE=$HOME/.zsh_history
SAVEHIST=1000
HISTSIZE=999
setopt HIST_EXPIRE_DUPS_FIRST
setopt EXTENDED_HISTORY

# Start typing + [Up-Arrow] - fuzzy find history forward
autoload -U up-line-or-beginning-search
zle -N up-line-or-beginning-search
bindkey '\e[A' up-line-or-beginning-search
# Start typing + [Down-Arrow] - fuzzy find history backward
autoload -U down-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '\e[B' down-line-or-beginning-search

# Path
addToPathFront() {
  if [[ "$PATH" != *"$1"* ]]; then
    export PATH=$1:$PATH
  fi
}
addToPathFront $HOME/bin:/usr/local/bin
addToPathFront $HOME/.local/bin
addToPathFront $HOME/.local/scripts
addToPathFront $HOME/.yarn/bin
addToPathFront $HOME/.config/yarn/global/node_modules/.bin
addToPathFront $HOME/.cargo/bin
addToPathFront $HOME/go/bin

export VISUAL=nvim
export EDITOR="$VISUAL"

export CLICOLOR=1
export LSCOLORS=ExGxBxDxCxEgEdxbxgxcxd

alias pi="ssh 192.168.86.33"

alias dots="$(which git) --git-dir=$HOME/.dots --work-tree=$HOME"
alias nixbuild="sudo nixos-rebuild switch --flake ~/.config/nixos"
alias nixclean="sudo nix-env -p /nix/var/nix/profiles/system --delete-generations old && nix-collect-garbage -d"

alias vi="nvim"
alias ll="ls -alG"
cl() { cd "$@" && ls; }

bindkey -s ^f "tmux-sessionizer.sh\n"

# eval "$(direnv hook zsh)"

if [ -f ~/.zshrc.local ]; then
  # Import local settings
  source ~/.zshrc.local
fi

# zprof
