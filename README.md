# dots
my dotfiles

## Setup Instructions

### Install Brew
`/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`

### Install Git
`git --version` on macOS this will prompt to install xcode tools that come with git

`brew install git`

`sudo dnf install git`

`sudo apt install git`

### Setup dots
`git clone --bare https://www.github.com/nickhackford/dots $HOME/.dots`

`alias dots="/usr/bin/git --git-dir=$HOME/.dots --work-tree=$HOME"`

`echo ".dots" >> .gitignore`

`dots checkout`

`dots submodule update --init`

`dots config --local status.showUntrackedFiles no`


### Install other dependencies
[Nerdfont](https://www.nerdfonts.com/)

`sudo dnf install`

`pacman -S`

`brew install`

`zsh neofetch neovim alacritty ripgrep nodejs make gcc gcc-c++ fzf tmux btop`

### Install Brave

### Final config

`chsh -s /bin/zsh`
