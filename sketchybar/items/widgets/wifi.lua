local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

local function isInternetConnected(callback)
    -- Nested sbar.exec callbacks never fire in SbarLua, so route, interface
    -- detection and the association check have to happen in one flat
    -- command. Connected just means there's a working default route; the
    -- Wi-Fi checks only run when Wi-Fi is that route. getairportpower is
    -- the authoritative check for whether Wi-Fi is even on; getsummary's
    -- SSID line can report stale/cached data even after Wi-Fi has been
    -- switched off, so power state must be checked first.
    sbar.exec(
        "iface=$(route get default 2>/dev/null | awk '/interface:/ {print $2}'); "
        .. "dev=$(networksetup -listallhardwareports "
        .. "| awk '/Wi-Fi|AirPort/{getline; print $2; exit}'); "
        .. "if [ -z \"$iface\" ]; then echo 'disconnected'; "
        .. "elif [ \"$iface\" != \"$dev\" ]; then echo 'connected'; "
        .. "else power=$(networksetup -getairportpower \"$dev\" 2>/dev/null); "
        .. "if echo \"$power\" | grep -q 'Off'; then echo 'disconnected'; "
        .. "elif ipconfig getsummary \"$dev\" 2>/dev/null | grep -q ' SSID :'; "
        .. "then echo 'connected'; "
        .. "else echo 'disconnected'; fi; fi",
        function(result)
            callback(result ~= nil and result:match("connected") ~= nil and result:match("disconnected") == nil)
        end
    )
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
    update_freq = 5,
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

-- Polling uses sketchybar's native update_freq/routine mechanism,
-- shell loops proved too fragile here (dead callbacks, piled up
-- processes across reloads).
wifi:subscribe({ "routine", "system_woke" }, update_wifi_status)

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

        -- Get network name (SSID if WiFi is the active route, hostname otherwise).
        -- Flat single exec, nested callbacks never fire in SbarLua. The
        -- branch is driven by the same interface check as the status icon.
        -- getairportnetwork is broken on newer macOS so we read the SSID
        -- from ipconfig getsummary, same as the status check does.
        sbar.exec(
            "iface=$(route get default 2>/dev/null | awk '/interface:/ {print $2}'); "
            .. "dev=$(networksetup -listallhardwareports "
            .. "| awk '/Wi-Fi|AirPort/{getline; print $2; exit}'); "
            .. "if [ \"$iface\" = \"$dev\" ] && [ -n \"$dev\" ]; then "
            .. "out=$(ipconfig getsummary \"$dev\" 2>/dev/null "
            .. "| awk -F' : ' '/ SSID :/{print $2}'); "
            .. "if [ -n \"$out\" ]; then echo \"$out\"; "
            .. "else hostname -s 2>/dev/null; fi; "
            .. "else hostname -s 2>/dev/null; fi",
            function(result)
                if result and result ~= "" then
                    ssid:set({ label = result:gsub("%s+$", "") })
                else
                    ssid:set({ label = "Wired" })
                end
            end
        )

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
