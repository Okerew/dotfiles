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

-- Single item: icon slot = artist (small, grey, shifted up),
-- label slot = title (larger, shifted down). One bounding box means
-- they stay adjacent regardless of text length, unlike two separate items.
local media_info = sbar.add("item", {
    position = "right",
    drawing = false,
    scroll_texts = true,
    padding_left = 10,
    padding_right = 10,
    icon = {
        string = "",
        font = {
            family = "JetBrains Mono NL",
            style = "Regular",
            size = 9,
        },
        color = colors.with_alpha(colors.white, 0.6),
        width = 0,
        y_offset = 6,
    },
    label = {
        string = "",
        font = { size = 11, family = "JetBrains Mono" },
        width = 0,
        max_chars = 20,
        y_offset = -5,
    },
})

-- Zero-width always-active item used solely to receive media_change events.
-- Items with drawing=false may not receive events in some sketchybar versions,
-- so this watcher stays drawing=true but takes up no visible space.
local media_watcher = sbar.add("item", {
    position = "right",
    drawing = true,
    width = 0,
    label = { drawing = false },
    icon = { drawing = false },
    background = { drawing = false },
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

local previous_state = {
    title = nil,
    artist = nil,
    app_running = false,
    is_playing = false,
}

local function truncate(str, n)
    if str and #str > n then
        return str:sub(1, n - 1) .. "…"
    end
    return str or ""
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
    local has_info = title ~= nil and title ~= "" and artist ~= nil and artist ~= ""

    if not title then
        if not previous_state.app_running then return end
        media_info:set({ drawing = false, icon = { width = 0 }, label = { width = 0 } })
        media_cover:set({ drawing = false })
        previous_state.title = nil
        previous_state.artist = nil
        previous_state.app_running = false
        previous_state.is_playing = false
        return
    end

    local title_changed = title ~= previous_state.title
    local artist_changed = artist ~= previous_state.artist
    local first_show = not previous_state.app_running
    local play_state_changed = is_playing ~= previous_state.is_playing

    if not title_changed and not artist_changed and not first_show and not play_state_changed then
        return
    end

    local display_title = has_info and title or "No Track"
    local display_artist = has_info and artist or (app_name or "Music")

    if title_changed or artist_changed or first_show then
        media_info:set({
            drawing = true,
            icon = { string = truncate(display_artist, 15), width = 0 },
            label = { string = display_title, width = 0 },
        })
        sbar.animate("tanh", 30, function()
            media_info:set({ icon = { width = "dynamic" }, label = { width = "dynamic" } })
        end)
    else
        media_info:set({ drawing = true })
        sbar.animate("tanh", 30, function()
            media_info:set({ icon = { width = "dynamic" }, label = { width = "dynamic" } })
        end)
    end

    media_cover:set({ drawing = is_playing })

    previous_state.title = title
    previous_state.artist = artist
    previous_state.app_running = true
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

-- Poll every 5 seconds using a recursive one-shot pattern.
-- sbar.exec only fires its callback on process exit, so "while true" never
-- triggers. Each call spawns a short-lived process that exits after 5s.
local function schedule_poll()
    sbar.exec("sleep 5 && echo tick", function()
        update_media_info()
        schedule_poll()
    end)
end

-- media_watcher is drawing=true so it reliably receives media_change events.
-- media_cover is drawing=false and may be silently skipped by sketchybar.
media_watcher:subscribe("media_change", function(env)
    update_media_info()
end)

media_cover:subscribe("media_change", function(env)
    update_media_info()
end)

sbar.add("event", "media_app_check")

media_cover:subscribe("media_app_check", function(env)
    update_media_info()
end)

media_cover:subscribe("mouse.clicked", function(env)
    media_cover:set({ popup = { drawing = "toggle" } })
    update_media_info()
end)

media_info:subscribe("mouse.clicked", function(env)
    media_cover:set({ popup = { drawing = "toggle" } })
    update_media_info()
end)

media_info:subscribe("mouse.exited.global", function(env)
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

update_media_info()
schedule_poll()
