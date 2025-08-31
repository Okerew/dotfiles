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
	drawing = false, -- Start hidden
	updates = true,
	popup = {
		align = "center",
		horizontal = true,
	},
})

local media_artist = sbar.add("item", {
	position = "right",
	drawing = false, -- Start hidden
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
		font = { size = 11, family = "Jetbrains Mono" },
		width = 0,
		max_chars = 30,
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
	click_script = "osascript -e 'tell application \"Spotify\" to previous track'",
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
	click_script = "osascript -e 'tell application \"Spotify\" to playpause'",
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
	click_script = "osascript -e 'tell application \"Spotify\" to next track'",
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

local function is_spotify_running()
	local handle = io.popen("pgrep -x Spotify > /dev/null 2>&1 && echo 'true' || echo 'false'")
	local result = handle:read("*a"):gsub("%s+$", "")
	handle:close()
	return result == "true"
end

local function is_music_running()
	local handle = io.popen("pgrep -x Music > /dev/null 2>&1 && echo 'true' || echo 'false'")
	local result = handle:read("*a"):gsub("%s+$", "")
	handle:close()
	return result == "true"
end

local function get_spotify_info()
	if not is_spotify_running() then
		return nil, nil, nil, nil, nil, nil
	end

	local title_handle = io.popen([[osascript -e 'tell application "Spotify"
		if player state is playing then
			return name of current track & "|" & artist of current track & "|playing" & "|" & player position & "|" & duration of current track
		else
			return name of current track & "|" & artist of current track & "|paused" & "|" & player position & "|" & duration of current track
		end if
	end tell' 2>/dev/null]])
	local result = title_handle:read("*a"):gsub("%s+$", "")
	title_handle:close()
	if result and result ~= "" then
		local parts = {}
		for part in result:gmatch("([^|]+)") do
			table.insert(parts, part)
		end
		if #parts >= 5 then
			return parts[1], parts[2], parts[3], parts[4], parts[5], "Spotify"
		end
	end
	return nil, nil, nil, nil, nil, nil
end

local function get_music_info()
	if not is_music_running() then
		return nil, nil, nil, nil, nil, nil
	end

	local music_handle = io.popen([[osascript -e 'tell application "Music"
		if player state is playing then
			return name of current track & "|" & artist of current track & "|playing" & "|" & player position & "|" & duration of current track
		else
			return name of current track & "|" & artist of current track & "|paused" & "|" & player position & "|" & duration of current track
		end if
	end tell' 2>/dev/null]])
	local result = music_handle:read("*a"):gsub("%s+$", "")
	music_handle:close()
	if result and result ~= "" then
		local parts = {}
		for part in result:gmatch("([^|]+)") do
			table.insert(parts, part)
		end
		if #parts >= 5 then
			return parts[1], parts[2], parts[3], parts[4], parts[5], "Music"
		end
	end
	return nil, nil, nil, nil, nil, nil
end

local function update_media_info()
	os.execute("echo 'Checking media info...' >> /tmp/sketchybar_debug.log")

	-- Check if either app is running first
	local spotify_running = is_spotify_running()
	local music_running = is_music_running()
	local any_app_running = spotify_running or music_running

	-- If no apps are running and we weren't showing anything before, skip update
	if not any_app_running and not previous_state.app_running then
		return
	end

	-- If apps stopped running, hide widgets
	if not any_app_running and previous_state.app_running then
		media_title:set({ drawing = false })
		media_artist:set({ drawing = false })
		media_cover:set({ drawing = false })
		previous_state.app_running = false
		previous_state.title = nil
		previous_state.artist = nil
		previous_state.is_playing = false
		os.execute("echo 'Apps stopped running, hiding widgets' >> /tmp/sketchybar_debug.log")
		return
	end

	local title, artist, state, position, duration, app = get_spotify_info()
	if not title then
		title, artist, state, position, duration, app = get_music_info()
	end

	local is_playing = (state == "playing")

	-- Check if anything actually changed
	local title_changed = title ~= previous_state.title
	local artist_changed = artist ~= previous_state.artist
	local app_state_changed = any_app_running ~= previous_state.app_running
	local play_state_changed = is_playing ~= previous_state.is_playing

	-- Only update if something changed
	if not (title_changed or artist_changed or app_state_changed or play_state_changed) then
		return
	end

	os.execute(
		string.format(
			"echo 'Change detected - App: %s, Title: %s, Artist: %s, State: %s' >> /tmp/sketchybar_debug.log",
			app or "none",
			title or "none",
			artist or "none",
			state or "none"
		)
	)

	if title and artist and title ~= "" and artist ~= "" then
		-- Only animate if the content actually changed or app just started
		if title_changed or artist_changed or app_state_changed then
			media_title:set({
				drawing = true,
				label = { string = title, width = "dynamic" },
			})
			media_artist:set({
				drawing = true,
				label = { string = artist, width = "dynamic" },
			})

			-- Animate when song changes or app starts
			if title_changed or artist_changed then
				animate_detail(true)
				interrupt = interrupt + 1
			end
		end

		media_cover:set({ drawing = is_playing })

		-- Only trigger animation when play state changes to playing (but not for song changes, handled above)
		if is_playing and play_state_changed and not (title_changed or artist_changed) then
			animate_detail(true)
			interrupt = interrupt + 1
		end
	else
		-- App is running but no track info available
		if app_state_changed or title_changed or artist_changed then
			media_title:set({
				drawing = true,
				label = { string = "No Track", width = "dynamic" },
			})
			media_artist:set({
				drawing = true,
				label = { string = app or "Music App", width = "dynamic" },
			})
		end
		media_cover:set({ drawing = false })
	end

	-- Update previous state
	previous_state.title = title
	previous_state.artist = artist
	previous_state.app_running = any_app_running
	previous_state.is_playing = is_playing
end

-- Create custom events for app monitoring
sbar.add("event", "media_app_check")

-- Subscribe to media change events
media_cover:subscribe("media_change", function(env)
	os.execute("echo 'media_change event received' >> /tmp/sketchybar_debug.log")
	update_media_info()
end)

-- Subscribe to our custom event
media_cover:subscribe("media_app_check", function(env)
	update_media_info()
end)

-- Mouse interactions
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

-- Start a background process to monitor app launches/quits
os.execute([[
nohup sh -c '
while true; do
  # Wait for process changes using a more efficient approach
  if pgrep -x "Spotify|Music" > /dev/null 2>&1; then
    sketchybar --trigger media_app_check > /dev/null 2>&1
  else
    sketchybar --trigger media_app_check > /dev/null 2>&1
  fi
  sleep 2
done
' > /dev/null 2>&1 &
]])

-- Initial update
update_media_info()
