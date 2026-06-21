#!/bin/bash
STATE_FILE="/tmp/spicetify_theme_state"
apply_theme() {
    if defaults read -g AppleInterfaceStyle 2>/dev/null \
        | grep -q Dark; then
        NEW_THEME="dark"
        NEW_SCHEME="Nord-Dark"
    else
        NEW_THEME="light"
        NEW_SCHEME="Nord-Light"
    fi
    if [ -f "$STATE_FILE" ] && \
        [ "$(cat "$STATE_FILE")" = "$NEW_THEME" ]; then
        return
    fi
    echo "$NEW_THEME" > "$STATE_FILE"
    spicetify config color_scheme "$NEW_SCHEME"
    spicetify apply
}
while true; do
    apply_theme
    sleep 5
done
