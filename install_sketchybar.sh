#!/usr/bin/env bash
set -euo pipefail

if ! command -v brew &>/dev/null; then
  echo "Homebrew is required. Install it first: https://brew.sh"
  exit 1
fi

if ! brew list sketchybar &>/dev/null; then
  echo "==> Installing sketchybar..."
  brew install FelixKratz/formulae/sketchybar
fi

if ! brew list lua &>/dev/null; then
  echo "==> Installing lua..."
  brew install lua
fi

echo "==> Building SbarLua for $(lua -v 2>&1)..."
SBARLUA_TMP=$(mktemp -d)
git clone --depth 1 https://github.com/FelixKratz/SbarLua.git "$SBARLUA_TMP"
(cd "$SBARLUA_TMP" && make install)
rm -rf "$SBARLUA_TMP"
cd $HOME/.config/sketchybar/helpers && make
echo "==> SbarLua installed"

echo "==> Starting sketchybar..."
brew services restart sketchybar 2>/dev/null || brew services start sketchybar

echo "==> Done"
