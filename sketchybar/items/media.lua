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
	drawing = true,
	updates = true,
	popup = {
		align = "center",
		horizontal = true,
	},
})
local media_artist = sbar.add("item", {
	position = "right",
	drawing = true,
	padding_left = 8,
	padding_right = 5,
	width = 0,
	icon = { drawing = false },
	label = {
		string = "No Media",
		width = 0, -- Start collapsed
		font = { size = 9 },
		color = colors.with_alpha(colors.white, 0.6),
		max_chars = 5,
		y_offset = 6,
	},
})
local media_title = sbar.add("item", {
	position = "right",
	drawing = true,
	padding_left = 0,
	padding_right = 8,
	icon = { drawing = false },
	label = {
		string = "Testing AppleScript",
		font = { size = 11, family = "SF Pro" },
		width = 0, -- Start collapsed
		max_chars = 20,
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
	click_script = "osascript -e 'tell application \"Spotify\" to previous track'", -- Adjusted for Spotify
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
	click_script = "osascript -e 'tell application \"Spotify\" to playpause'", -- Adjusted for Spotify
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
	click_script = "osascript -e 'tell application \"Spotify\" to next track'", -- Adjusted for Spotify
})
local interrupt = 0
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
local function get_spotify_info()
	local title_handle = io.popen([[osascript -e 'tell application "Spotify"
    if it is running then
      if player state is playing then
        return name of current track & "|" & artist of current track & "|playing" & "|" & player position & "|" & duration of current track
      else
        return name of current track & "|" & artist of current track & "|paused" & "|" & player position & "|" & duration of current track
      end if
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
	local music_handle = io.popen([[osascript -e 'tell application "Music"
    if it is running then
      if player state is playing then
        return name of current track & "|" & artist of current track & "|playing" & "|" & player position & "|" & duration of current track
      else
        return name of current track & "|" & artist of current track & "|paused" & "|" & player position & "|" & duration of current track
      end if
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
	local title, artist, state, position, duration, app = get_spotify_info()
	if not title then
		title, artist, state, position, duration, app = get_music_info()
	end
	os.execute(
		string.format(
			"echo 'Found - App: %s, Title: %s, Artist: %s, State: %s, Position: %s, Duration: %s' >> /tmp/sketchybar_debug.log",
			app or "none",
			title or "none",
			artist or "none",
			state or "none",
			position or "none",
			duration or "none"
		)
	)
	if title and artist and title ~= "" and artist ~= "" then
		media_title:set({
			drawing = true,
			label = { string = title, width = "dynamic" },
		})
		media_artist:set({
			drawing = true,
			label = { string = artist, width = "dynamic" },
		})
		local is_playing = (state == "playing")
		media_cover:set({ drawing = is_playing })
		if is_playing then
			animate_detail(true)
			interrupt = interrupt + 1
		end
	else
		media_title:set({
			drawing = true,
			label = { string = "No Music Playing", width = "dynamic" },
		})
		media_artist:set({
			drawing = true,
			label = { string = "Open Spotify/Music", width = "dynamic" },
		})
		media_cover:set({ drawing = false })
	end
end
media_cover:subscribe("media_change", function(env)
	os.execute("echo 'media_change event received' >> /tmp/sketchybar_debug.log")
	update_media_info()
end)
sbar.add("item", {
	position = "popup." .. media_cover.name,
	updates = 3,
	drawing = false,
	icon = { drawing = false },
	label = { drawing = false },
}):subscribe("routine", function(env)
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
update_media_info()
