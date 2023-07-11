# zmodload zsh/zprof

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
# if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#   source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
# fi

[ -f "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh" ] && source "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh"
plug "zsh-users/zsh-autosuggestions"
plug "zsh-users/zsh-syntax-highlighting"
plug "zap-zsh/vim"
plug "romkatv/powerlevel10k"

autoload -U compinit && compinit

source ~/.local/share/zap/plugins/powerlevel10k/config/p10k-robbyrussell.zsh
source ~/.config/zsh/.p10k.zsh
zstyle ':omz:plugins:nvm' lazy yes
source ~/.config/zsh/nvm.plugin.zsh

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

# export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

export VISUAL=nvim
export EDITOR="$VISUAL"

export CLICOLOR=1
export LSCOLORS=ExGxBxDxCxEgEdxbxgxcxd

alias dots="/usr/bin/git --git-dir=$HOME/.dots --work-tree=$HOME"
alias vi="nvim"
alias ll="ls -alG"

bindkey -s ^f "tmux-sessionizer.sh\n"

if [ -f ~/.zshrc.local ]; then
  # Import local settings
  source ~/.zshrc.local
fi

# zprof
