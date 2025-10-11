local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

local function isInternetConnected(callback)
	-- Simple ping test - if we can reach the internet, we're connected
	sbar.exec("ping -c 1 -W 2000 8.8.8.8 2>/dev/null", function(ping_result)
		local connected = ping_result and string.find(ping_result, "bytes from") ~= nil
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

-- Subscribe to network change events and system wake
wifi:subscribe({ "wifi_change", "system_woke", "network_update" }, update_wifi_status)

-- More frequent updates to catch reconnections
sbar.exec("while true; do echo 'network_update'; sleep 3; done", function()
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

		-- Get hostname
		sbar.exec("networksetup -getcomputername", function(result)
			hostname:set({ label = result:gsub("%s+$", "") })
		end)

		-- Get active interface and then IP
		sbar.exec("route get default 2>/dev/null | awk '/interface:/ {print $2}' | head -1", function(interface)
			local active_interface = interface and interface:gsub("%s+", "") or "en0"

			-- Get IP address from active interface
			sbar.exec(
				"ifconfig " .. active_interface .. " | awk '/inet / && !/127.0.0.1/ {print $2}' | head -1",
				function(result)
					if result and result ~= "" then
						ip:set({ label = result:gsub("%s+$", "") })
					else
						-- Fallback: try other common interfaces
						sbar.exec(
							"ifconfig | awk '/inet / && !/127.0.0.1/ && !/169.254/ {print $2}' | head -1",
							function(fallback_ip)
								ip:set({ label = fallback_ip and fallback_ip:gsub("%s+$", "") or "Not connected" })
							end
						)
					end
				end
			)

			-- Get subnet mask (convert from hex to dotted decimal)
			sbar.exec(
				"ifconfig " .. active_interface .. " | awk '/inet / && !/127.0.0.1/ {print $4}' | head -1",
				function(result)
					if result and result ~= "" and result ~= "0x0" then
						-- Convert hex subnet mask to dotted decimal notation
						local hex_mask = result:gsub("0x", ""):gsub("%s+$", "")
						if #hex_mask == 8 then
							local function hex_to_dec(hex_str)
								return tonumber(hex_str, 16)
							end

							local oct1 = hex_to_dec(hex_mask:sub(1, 2))
							local oct2 = hex_to_dec(hex_mask:sub(3, 4))
							local oct3 = hex_to_dec(hex_mask:sub(5, 6))
							local oct4 = hex_to_dec(hex_mask:sub(7, 8))

							local dotted_mask = oct1 .. "." .. oct2 .. "." .. oct3 .. "." .. oct4
							mask:set({ label = dotted_mask })
						else
							-- Fallback: try to get netmask differently
							sbar.exec(
								"route -n get default 2>/dev/null | awk '/interface:/ {print $2}' | xargs -I {} ifconfig {} | awk '/netmask/ {print $4}' | head -1",
								function(fallback_result)
									if fallback_result and fallback_result ~= "" then
										mask:set({ label = fallback_result:gsub("%s+$", "") })
									else
										mask:set({ label = "255.255.255.0" }) -- common default
									end
								end
							)
						end
					else
						mask:set({ label = "255.255.255.0" }) -- common default
					end
				end
			)
		end)

		-- Get network name (SSID if WiFi, hostname if wired)
		sbar.exec("networksetup -getairportnetwork en0 2>/dev/null", function(result)
			if
				result
				and result ~= ""
				and not string.find(result, "not associated")
				and not string.find(result, "not a Wi-Fi interface")
				and not string.find(result, "Error")
			then
				-- Extract SSID from "Current Wi-Fi Network: NetworkName"
				local ssid_name = result:match(":%s*(.+)")
				if ssid_name then
					ssid:set({ label = ssid_name:gsub("%s+$", "") })
				else
					ssid:set({ label = result:gsub("%s+$", "") })
				end
			else
				-- Not WiFi or error - show hostname instead
				sbar.exec("hostname -s 2>/dev/null", function(hostname_result)
					ssid:set({ label = hostname_result and hostname_result:gsub("%s+$", "") or "Wired" })
				end)
			end
		end)

		-- Get router IP
		sbar.exec("route get default 2>/dev/null | awk '/gateway:/ {print $2}' | head -1", function(result)
			if result and result ~= "" then
				router:set({ label = result:gsub("%s+$", "") })
			else
				router:set({ label = "N/A" })
			end
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
