echo "Installing Dependencies"

curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

curl -L https://sh.distant.dev | sh

brew tap homebrew-zathura/zathura
brew install zathura

brew install switchaudio-osx
brew install nowplaying-cli

brew tap FelixKratz/formulae
brew install borders

brew install --cask sf-symbols
brew install --cask font-sf-mono
brew install --cask font-sf-pro

echo "Cloning Config"
git clone https://github.com/Okerew/dotfiles /tmp/dotfiles

BORDERS_PATH="$(brew --prefix borders)/share/borders"
mkdir -p $HOME/.config/borders
cp -r "$BORDERS_PATH"/* $HOME/.config/borders/

mv /tmp/dotfiles/borders $HOME/.config/borders
brew services start borders

mkdir -p ~/.config/nvim
mv /tmp/dotfiles/nvim/* ~/.config/nvim/

python3 -m venv ~/.local/venv/nvim
source ~/.local/venv/nvim/bin/activate
pip install pynvim

echo "Installing tmux"
brew install tmux

mkdir -p $HOME/.config/tmux
mv /tmp/dotfiles/tmux/* $HOME/.config/tmux/

git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

rm -rf /tmp/dotfiles
