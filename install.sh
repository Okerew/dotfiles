#!/bin/bash

ask() {
    local prompt="$1"
    local var="$2"
    read -r -p "$prompt [y/N] " "$var"
}

echo "Installing config"
echo ""

ask "Install SketchyBar (status bar)?" install_sketchybar
ask "Install Yabai (tiling window manager)?" install_yabai
ask "Install skhd (hotkey daemon)?" install_skhd
ask "Install Spicetify (Spotify customization)?" install_spicetify
ask "Install VencordAutoInstaller?" install_vencord
ask "Install Anaconda?" install_anaconda
ask "Install BlackHole 2ch (virtual audio driver)?" install_blackhole
ask "Install btop (system monitor)?" install_btop
ask "Install RustNet?" install_rustnet
ask "Install tmux?" install_tmux
ask "Install kitty (terminal emulator)?" install_kitty

echo ""
echo "Starting installation..."
echo ""

curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim \
    --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

curl -L https://sh.distant.dev | sh

brew install switchaudio-osx

if [[ "$install_sketchybar" =~ ^[Yy]$ ]]; then
    brew tap FelixKratz/formulae
    brew install sketchybar
fi

if [[ "$install_yabai" =~ ^[Yy]$ ]]; then
    brew install koekeishiya/formulae/yabai
fi

if [[ "$install_skhd" =~ ^[Yy]$ ]]; then
    brew install skhd
fi

if [[ "$install_spicetify" =~ ^[Yy]$ ]]; then
    brew install spicetify
fi

if [[ "$install_blackhole" =~ ^[Yy]$ ]]; then
    brew install --cask blackhole-2ch
fi

if [[ "$install_anaconda" =~ ^[Yy]$ ]]; then
    brew install --cask anaconda
fi

brew install --cask sf-symbols
brew install --cask font-sf-mono
brew install --cask font-sf-pro

if [[ "$install_rustnet" =~ ^[Yy]$ ]]; then
    brew tap domcyrus/rustnet
    brew install rustnet
fi

if [[ "$install_btop" =~ ^[Yy]$ ]]; then
    mkdir -p "$HOME/.config/btop"
    mv /tmp/dotfiles/btop/* "$HOME/.config/btp/"
    brew install btop
fi

if [[ "$install_sketchybar" =~ ^[Yy]$ ]]; then
    curl -L https://github.com/kvndrsslr/sketchybar-app-font/releases/download/v2.0.28/sketchybar-app-font.ttf \
        -o $HOME/Library/Fonts/sketchybar-app-font.ttf

    (
        git clone https://github.com/FelixKratz/SbarLua.git /tmp/SbarLua \
        && cd /tmp/SbarLua/ \
        && make install \
        && rm -rf /tmp/SbarLua/
    )
fi

git clone https://github.com/Okerew/dotfiles /tmp/dotfiles

if [[ "$install_sketchybar" =~ ^[Yy]$ ]]; then
    mv "$HOME/.config/sketchybar" "$HOME/.config/sketchybar_backup" 2>/dev/null
    mv /tmp/dotfiles/sketchybar "$HOME/.config/sketchybar"
fi

mkdir -p ~/.nvim/config
mv /tmp/dotfiles/nvim/* ~/.nvim/config/

if [[ "$install_tmux" =~ ^[Yy]$ ]]; then
    brew install tmux

    mkdir -p "$HOME/.config/tmux"
    mv /tmp/dotfiles/tmux/* "$HOME/.config/tmux/"

    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

if [[ "$install_yabai" =~ ^[Yy]$ ]]; then
    mv /tmp/dotfiles/yabai "$HOME/.config/yabai"
fi

if [[ "$install_skhd" =~ ^[Yy]$ ]]; then
    mv /tmp/dotfiles/.skhdrc "$HOME/"
fi

mv /tmp/dotfiles/.zshrc "$HOME/"

if [[ "$install_kitty" =~ ^[Yy]$ ]]; then
    brew install --cask kitty
fi

if [[ "$install_vencord" =~ ^[Yy]$ ]]; then
    git clone https://github.com/Okerew/VencordInstaller.git
    mv VencordInstaller "$HOME/"
    cd "$HOME/VencordInstaller/"
    bash install.sh
fi

rm -rf /tmp/dotfiles

if [[ "$install_sketchybar" =~ ^[Yy]$ ]]; then
    brew services start sketchybar
fi

if [[ "$install_yabai" =~ ^[Yy]$ ]]; then
    yabai --start-service
fi

if [[ "$install_skhd" =~ ^[Yy]$ ]]; then
    skhd --start-service
fi

if [[ "$install_spicetify" =~ ^[Yy]$ ]]; then
    spicetify apply
fi

echo ""
echo "Config Installed"
