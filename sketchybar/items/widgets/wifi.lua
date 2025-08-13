local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

local function isInternetConnected(callback)
	sbar.exec("ping -c 1 8.8.8.8", function(result)
		local connected = string.find(result, "bytes from") ~= nil
		callback(connected)
	end)
end

local popup_width = 250

local wifi = sbar.add("item", "widgets.wifi", {
	position = "right",
	icon = {
		padding_right = 0,
		font = {
			style = settings.font.style_map["Bold"],
			size = 12.0,
		},
		string = icons.wifi.disconnected,
		color = colors.red,
	},
	label = { drawing = false },
})

local wifi_bracket = sbar.add("bracket", "widgets.wifi.bracket", {
	wifi.name,
}, {
	background = { color = colors.bg1 },
	popup = { align = "center", height = 30 },
})

local ssid = sbar.add("item", {
	position = "popup." .. wifi_bracket.name,
	icon = {
		font = { style = settings.font.style_map["Bold"] },
		string = icons.wifi.router,
	},
	width = popup_width,
	align = "center",
	label = {
		font = {
			size = 15,
			style = settings.font.style_map["Bold"],
		},
		max_chars = 18,
		string = "????????????",
	},
	background = {
		height = 2,
		color = colors.grey,
		y_offset = -15,
	},
})

local hostname = sbar.add("item", {
	position = "popup." .. wifi_bracket.name,
	icon = {
		align = "left",
		string = "Hostname:",
		width = popup_width / 2,
	},
	label = {
		max_chars = 20,
		string = "????????????",
		width = popup_width / 2,
		align = "right",
	},
})

local ip = sbar.add("item", {
	position = "popup." .. wifi_bracket.name,
	icon = {
		align = "left",
		string = "IP:",
		width = popup_width / 2,
	},
	label = {
		string = "???.???.???.???",
		width = popup_width / 2,
		align = "right",
	},
})

local mask = sbar.add("item", {
	position = "popup." .. wifi_bracket.name,
	icon = {
		align = "left",
		string = "Subnet mask:",
		width = popup_width / 2,
	},
	label = {
		string = "???.???.???.???",
		width = popup_width / 2,
		align = "right",
	},
})

local router = sbar.add("item", {
	position = "popup." .. wifi_bracket.name,
	icon = {
		align = "left",
		string = "Router:",
		width = popup_width / 2,
	},
	label = {
		string = "???.???.???.???",
		width = popup_width / 2,
		align = "right",
	},
})

sbar.add("item", { position = "right", width = settings.group_paddings })

local function update_wifi_status()
	isInternetConnected(function(connected)
		if connected then
			wifi:set({
				icon = {
					string = icons.wifi.connected,
					color = colors.white,
				},
			})
		else
			wifi:set({
				icon = {
					string = icons.wifi.disconnected,
					color = colors.red,
				},
			})
		end
	end)
end

wifi:subscribe({ "wifi_change", "system_woke" }, update_wifi_status)

sbar.exec("while true; do echo 'periodic_update'; sleep 5; done", function()
	update_wifi_status()
end)

-- Run once on load
update_wifi_status()

-- Popup toggle logic
local function hide_details()
	wifi_bracket:set({ popup = { drawing = false } })
end

local function toggle_details()
	local should_draw = wifi_bracket:query().popup.drawing == "off"
	if should_draw then
		wifi_bracket:set({ popup = { drawing = true } })
		sbar.exec("networksetup -getcomputername", function(result)
			hostname:set({ label = result })
		end)
		sbar.exec("ipconfig getifaddr en0", function(result)
			ip:set({ label = result })
		end)
		sbar.exec("ipconfig getsummary en0 | awk -F ' SSID : '  '/ SSID : / {print $2}'", function(result)
			ssid:set({ label = result })
		end)
		sbar.exec("networksetup -getinfo Wi-Fi | awk -F 'Subnet mask: ' '/^Subnet mask: / {print $2}'", function(result)
			mask:set({ label = result })
		end)
		sbar.exec("networksetup -getinfo Wi-Fi | awk -F 'Router: ' '/^Router: / {print $2}'", function(result)
			router:set({ label = result })
		end)
	else
		hide_details()
	end
end

wifi:subscribe("mouse.clicked", toggle_details)
wifi:subscribe("mouse.exited.global", hide_details)

local function copy_label_to_clipboard(env)
	local label = sbar.query(env.NAME).label.value
	sbar.exec('echo "' .. label .. '" | pbcopy')
	sbar.set(env.NAME, { label = { string = icons.clipboard, align = "center" } })
	sbar.delay(1, function()
		sbar.set(env.NAME, { label = { string = label, align = "right" } })
	end)
end

ssid:subscribe("mouse.clicked", copy_label_to_clipboard)
hostname:subscribe("mouse.clicked", copy_label_to_clipboard)
ip:subscribe("mouse.clicked", copy_label_to_clipboard)
mask:subscribe("mouse.clicked", copy_label_to_clipboard)
router:subscribe("mouse.clicked", copy_label_to_clipboard)
