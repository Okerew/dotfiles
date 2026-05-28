#!/bin/bash

THEME_DIR="$HOME/.config/kitty/themes"
TARGET="$HOME/.config/kitty/current-theme.conf"
STATE_FILE="/tmp/kitty_theme_state"

apply_theme() {
    if defaults read -g AppleInterfaceStyle 2>/dev/null | grep -q Dark; then
        NEW_THEME="dark"
        NEW_FILE="$THEME_DIR/nord-dark.conf"
    else
        NEW_THEME="light"
        NEW_FILE="$THEME_DIR/nord-light.conf"
    fi

    if [ -f "$STATE_FILE" ] && [ "$(cat "$STATE_FILE")" = "$NEW_THEME" ]; then
        return
    fi

    echo "$NEW_THEME" > "$STATE_FILE"

    ln -sfn "$NEW_FILE" "$TARGET"

    if pgrep -x kitty >/dev/null; then
        killall -SIGUSR1 kitty 2>/dev/null
    fi
}

while true; do
    apply_theme
    sleep 5
done
