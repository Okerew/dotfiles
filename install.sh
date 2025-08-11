echo "Installing Dependencies"

curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

curl -L https://sh.distant.dev | sh

brew tap homebrew-zathura/zathura
brew install zathura

brew install switchaudio-osx
brew install nowplaying-cli

brew tap FelixKratz/formulae
brew install sketchybar
brew install borders

brew install --cask sf-symbols
brew install --cask font-sf-mono
brew install --cask font-sf-pro

curl -L https://github.com/kvndrsslr/sketchybar-app-font/releases/download/v2.0.28/sketchybar-app-font.ttf -o $HOME/Library/Fonts/sketchybar-app-font.ttf

(git clone https://github.com/FelixKratz/SbarLua.git /tmp/SbarLua && cd /tmp/SbarLua/ && make install && rm -rf /tmp/SbarLua/)

echo "Cloning Config"
git clone https://github.com/Okerew/dotfiles /tmp/dotfiles

mv $HOME/.config/sketchybar $HOME/.config/sketchybar_backup

BORDERS_PATH="$(brew --prefix borders)/share/borders"
if [ -d "$BORDERS_PATH" ]; then
    mkdir -p $HOME/.config/borders
    cp -r "$BORDERS_PATH"/* $HOME/.config/borders/
else
    echo "Warning: Borders directory not found at $BORDERS_PATH"
fi

if [ -d /tmp/dotfiles/borders ]; then
    mv /tmp/dotfiles/borders $HOME/.config/borders
fi

mv /tmp/dotfiles/sketchybar $HOME/.config/sketchybar

mkdir -p ~/.nvim/config
mv /tmp/dotfiles/nvim/* ~/.nvim/config/

rm -rf /tmp/dotfiles

brew services start sketchybar

brew services start borders
