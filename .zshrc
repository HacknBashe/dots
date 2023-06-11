# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

autoload -Uz compinit
source ~/.zsh/powerlevel10k/powerlevel10k.zsh-theme

# Path
addToPathFront() {
  if [[ "$PATH" != *"$1"* ]]; then
    export PATH=$1:$PATH
  fi
}
addToPathFront $HOME/bin:/usr/local/bin
addToPathFront $HOME/bin/.local/scripts
addToPathFront $HOME/.yarn/bin
addToPathFront $HOME/.config/yarn/global/node_modules/.bin

alias dots="/usr/bin/git --git-dir=$HOME/.dots --work-tree=$HOME"
alias vi="nvim"

compinit

bindkey -s ^f "tmux-sessionizer.sh\n"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

if [ -f ~/.zshrc.local ]; then
  # Import local settings
  source ~/.zshrc.local
fi
