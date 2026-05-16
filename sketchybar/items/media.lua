local icons = require("icons")
local colors = require("colors")

local media_cover = sbar.add("item", {
    position = "right",
    background = {
        image = {
            string = "media.artwork",
            scale = 0.85,
        },
        color = colors.transparent,
    },
    label = { drawing = false },
    icon = { drawing = false },
    drawing = false,
    updates = true,
    popup = {
        align = "center",
        horizontal = true,
    },
})

local media_artist = sbar.add("item", {
    position = "right",
    drawing = false,
    padding_left = 8,
    padding_right = 5,
    width = 0,
    icon = { drawing = false },
    label = {
        string = "No Media",
        width = 0,
        font = { size = 9 },
        color = colors.with_alpha(colors.white, 0.6),
        max_chars = 5,
        y_offset = 6,
    },
})

local media_title = sbar.add("item", {
    position = "right",
    drawing = false,
    padding_left = 10,
    padding_right = 10,
    icon = { drawing = false },
    label = {
        string = "Testing AppleScript",
        font = { size = 11, family = "JetBrains Mono" },
        width = 0,
        max_chars = 15,
        y_offset = -5,
    },
})

local media_prev = sbar.add("item", {
    position = "popup." .. media_cover.name,
    icon = {
        string = icons.media.back,
        color = colors.white,
        font = { size = 16 },
    },
    label = { drawing = false },
    background = {
        color = colors.with_alpha(colors.white, 0.1),
        corner_radius = 8,
        height = 32,
        border_width = 1,
        border_color = colors.with_alpha(colors.white, 0.2),
    },
    padding_left = 8,
    padding_right = 8,
})

local media_play_pause = sbar.add("item", {
    position = "popup." .. media_cover.name,
    icon = {
        string = icons.media.play_pause,
        color = colors.white,
        font = { size = 18 },
    },
    label = { drawing = false },
    background = {
        color = colors.with_alpha(colors.blue, 0.3),
        corner_radius = 8,
        height = 32,
        border_width = 1,
        border_color = colors.with_alpha(colors.blue, 0.4),
    },
    padding_left = 10,
    padding_right = 10,
})

local media_next = sbar.add("item", {
    position = "popup." .. media_cover.name,
    icon = {
        string = icons.media.forward,
        color = colors.white,
        font = { size = 16 },
    },
    label = { drawing = false },
    background = {
        color = colors.with_alpha(colors.white, 0.1),
        corner_radius = 8,
        height = 32,
        border_width = 1,
        border_color = colors.with_alpha(colors.white, 0.2),
    },
    padding_left = 8,
    padding_right = 8,
})

local interrupt = 0
local previous_state = {
    title = nil,
    artist = nil,
    app_running = false,
    is_playing = false,
}

local function animate_detail(detail)
    if not detail then
        interrupt = interrupt - 1
    end
    if interrupt > 0 and not detail then
        return
    end
    sbar.animate("tanh", 30, function()
        media_artist:set({ label = { width = detail and "dynamic" or 0 } })
        media_title:set({ label = { width = detail and "dynamic" or 0 } })
    end)
end

local function parse_track_info(result)
    if not result or result == "" then
        return nil
    end
    local parts = {}
    for part in result:gmatch("([^|]+)") do
        table.insert(parts, part)
    end
    if #parts >= 5 then
        return parts[1], parts[2], parts[3], parts[4], parts[5]
    end
    return nil
end

local function apply_media_update(title, artist, state, app_name)
    local is_playing = (state == "playing")
    local any_app_running = title ~= nil

    if not any_app_running and not previous_state.app_running then
        return
    end

    if not any_app_running and previous_state.app_running then
        media_title:set({ drawing = false })
        media_artist:set({ drawing = false })
        media_cover:set({ drawing = false })
        previous_state.title = nil
        previous_state.artist = nil
        previous_state.app_running = false
        previous_state.is_playing = false
        return
    end

    local title_changed = title ~= previous_state.title
    local artist_changed = artist ~= previous_state.artist
    local app_state_changed = any_app_running ~= previous_state.app_running
    local play_state_changed = is_playing ~= previous_state.is_playing

    if not (title_changed or artist_changed or app_state_changed or play_state_changed) then
        return
    end

    if title and artist and title ~= "" and artist ~= "" then
        if title_changed or artist_changed or app_state_changed then
            media_title:set({
                drawing = true,
                label = { string = title, width = "dynamic" },
            })
            media_artist:set({
                drawing = true,
                label = { string = artist, width = "dynamic" },
            })
            if title_changed or artist_changed then
                animate_detail(true)
                interrupt = interrupt + 1
            end
        end

        media_cover:set({ drawing = is_playing })

        if is_playing and play_state_changed and not (title_changed or artist_changed) then
            animate_detail(true)
            interrupt = interrupt + 1
        end
    else
        if app_state_changed or title_changed or artist_changed then
            media_title:set({
                drawing = true,
                label = { string = "No Track", width = "dynamic" },
            })
            media_artist:set({
                drawing = true,
                label = { string = app_name or "Music App", width = "dynamic" },
            })
        end
        media_cover:set({ drawing = false })
    end

    previous_state.title = title
    previous_state.artist = artist
    previous_state.app_running = any_app_running
    previous_state.is_playing = is_playing
end

local OSASCRIPT_SPOTIFY = [[osascript -e 'tell application "Spotify"
    set trackName to name of current track
    set artistName to artist of current track
    set playState to player state as string
    set pos to player position
    set dur to duration of current track
    return trackName & "|" & artistName & "|" & playState & "|" & pos & "|" & dur
end tell' 2>/dev/null]]

local OSASCRIPT_MUSIC = [[osascript -e 'tell application "Music"
    set trackName to name of current track
    set artistName to artist of current track
    set playState to player state as string
    set pos to player position
    set dur to duration of current track
    return trackName & "|" & artistName & "|" & playState & "|" & pos & "|" & dur
end tell' 2>/dev/null]]

local function update_media_info()
    sbar.exec("pgrep -x Spotify 2>/dev/null", function(result)
        if result and result ~= "" then
            sbar.exec(OSASCRIPT_SPOTIFY, function(r)
                local title, artist, state = parse_track_info(r)
                if title then
                    apply_media_update(title, artist, state, "Spotify")
                else
                    apply_media_update(nil, nil, nil, nil)
                end
            end)
            return
        end

        sbar.exec("pgrep -x Music 2>/dev/null", function(result2)
            if result2 and result2 ~= "" then
                sbar.exec(OSASCRIPT_MUSIC, function(r)
                    local title, artist, state = parse_track_info(r)
                    if title then
                        apply_media_update(title, artist, state, "Music")
                    else
                        apply_media_update(nil, nil, nil, nil)
                    end
                end)
            else
                apply_media_update(nil, nil, nil, nil)
            end
        end)
    end)
end

local function spotify_cmd(cmd)
    sbar.exec("pgrep -x Spotify 2>/dev/null", function(result)
        if result and result ~= "" then
            sbar.exec("osascript -e 'tell application \"Spotify\" to " .. cmd .. "' 2>/dev/null")
        end
    end)
end

sbar.add("event", "media_app_check")

media_cover:subscribe("media_change", function(env)
    update_media_info()
end)

media_cover:subscribe("media_app_check", function(env)
    update_media_info()
end)

media_cover:subscribe("mouse.clicked", function(env)
    media_cover:set({ popup = { drawing = "toggle" } })
    update_media_info()
end)

media_title:subscribe("mouse.clicked", function(env)
    media_cover:set({ popup = { drawing = "toggle" } })
    update_media_info()
end)

media_artist:subscribe("mouse.clicked", function(env)
    media_cover:set({ popup = { drawing = "toggle" } })
    update_media_info()
end)

media_title:subscribe("mouse.exited.global", function(env)
    media_cover:set({ popup = { drawing = false } })
end)

media_prev:subscribe("mouse.clicked", function(env)
    spotify_cmd("previous track")
end)

media_play_pause:subscribe("mouse.clicked", function(env)
    spotify_cmd("playpause")
end)

media_next:subscribe("mouse.clicked", function(env)
    spotify_cmd("next track")
end)

sbar.exec("while true; do sleep 5; echo 'tick'; done", function()
    update_media_info()
end)

update_media_info()
