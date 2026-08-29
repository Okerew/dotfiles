local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

local popup_width = 250

local bluetooth = sbar.add("item", "widgets.bluetooth", {
    position = "right",
    icon = {
        padding_right = 3,
        font = {
            style = settings.font.style_map["Bold"],
            size = 12.0,
        },
        string = icons.bluetooth.off,
        color = colors.red,
    },
    label = { drawing = false },
})

local bluetooth_bracket = sbar.add("bracket", "widgets.bluetooth.bracket", {
    bluetooth.name,
}, {
    background = { color = colors.bg1 },
    popup = { align = "center", height = 30 },
})

sbar.add("item", "widgets.bluetooth.padding", {
    position = "right",
    width = settings.group_paddings,
})

-- Tracks popup device items so we can clean them up on rebuild.
local device_items = {}

-- The popup open state is tracked here instead of querying the
-- bracket: a bracket without popup items has no "popup" key in
-- query results, so query().popup.drawing errors and kills the
-- click handler.
local popup_open = false

local function draw_popup()
    popup_open = true
    bluetooth_bracket:set({ popup = { drawing = true } })
end

local function clear_device_items()
    for _, name in ipairs(device_items) do
        sbar.remove(name)
    end
    device_items = {}
end

local function get_power_state(callback)
    sbar.exec("blueutil -p 2>/dev/null", function(result)
        local state = result and result:gsub("%s+", "") or "0"
        callback(state == "1")
    end)
end

local function update_bluetooth_status()
    get_power_state(function(on)
        if on then
            bluetooth:set({
                icon = {
                    string = icons.bluetooth.on,
                    color = colors.white,
                },
            })
        else
            bluetooth:set({
                icon = {
                    string = icons.bluetooth.off,
                    color = colors.red,
                },
            })
        end
    end)
end

-- Parses blueutil json into {address, name, connected} entries.
-- Minimal JSON-ish parser: blueutil json is a flat array of objects
-- with string/number/bool values, so a regex walk is enough and
-- avoids pulling in a json library.
local function parse_paired_devices(json, callback)
    local devices = {}
    if not json or json == "" then
        callback(devices)
        return
    end

    for obj in json:gmatch("{[^{}]-}") do
        local address = obj:match('"address"%s*:%s*"([^"]+)"')
        local name = obj:match('"name"%s*:%s*"([^"]*)"')
        local connected = obj:match('"connected"%s*:%s*(%a+)')
        if address then
            table.insert(devices, {
                address = address,
                name = (name and name ~= "") and name or address,
                connected = connected == "true",
            })
        end
    end
    callback(devices)
end

-- Single exec for both power state and paired devices, nested
-- sbar.exec callbacks never fire so this has to be flat.
local function rebuild_popup()
    sbar.exec(
        "blueutil -p 2>/dev/null; blueutil --paired --format json 2>/dev/null",
        function(result)
            clear_device_items()

            local power, json = (result or ""):match("^(%d)%s*(.*)$")
            local on = power == "1"

            -- Power toggle row at the top of the popup
            local power_label = on and "Bluetooth: On" or "Bluetooth: Off"
            local power_color = on and colors.green or colors.red
            local power_icon = on and icons.switch.on or icons.switch.off

            local power_item = sbar.add("item", "widgets.bluetooth.power", {
                position = "popup." .. bluetooth_bracket.name,
                icon = {
                    align = "left",
                    string = power_icon,
                    color = power_color,
                    width = popup_width / 2,
                },
                label = {
                    string = power_label,
                    color = power_color,
                    width = popup_width / 2,
                    align = "right",
                },
                background = {
                    height = 2,
                    color = colors.grey,
                    y_offset = -15,
                },
                click_script = "blueutil -p toggle",
            })
            table.insert(device_items, power_item.name)

            if not on then
                draw_popup()
                return
            end

            parse_paired_devices(json or "", function(devices)
                for _, device in ipairs(devices) do
                    local color = device.connected and colors.green
                        or colors.white
                    local status = device.connected and "  (connected)"
                        or ""
                    local addr = device.address

                    -- click_script runs in the shell, so we toggle via
                    -- blueutil based on the current state captured here.
                    local cmd
                    if device.connected then
                        cmd = "blueutil --disconnect " .. addr
                    else
                        cmd = "blueutil --connect " .. addr
                    end
                    cmd = cmd .. " && sketchybar --trigger bluetooth_update"

                    local item = sbar.add("item",
                        "widgets.bluetooth.device." .. addr, {
                            position = "popup." .. bluetooth_bracket.name,
                            icon = {
                                align = "left",
                                string = icons.bluetooth.on,
                                color = color,
                                width = popup_width / 2,
                            },
                            label = {
                                string = device.name .. status,
                                color = color,
                                width = popup_width / 2,
                                align = "right",
                                max_chars = 22,
                            },
                            click_script = cmd,
                        })
                    table.insert(device_items, item.name)
                end
                draw_popup()
            end)
        end
    )
end

local function hide_details()
    popup_open = false
    bluetooth_bracket:set({ popup = { drawing = false } })
end

local function toggle_details()
    if popup_open then
        hide_details()
    else
        -- rebuild_popup draws the popup itself once the items exist,
        -- drawing it empty here would close it again right away
        rebuild_popup()
    end
end

-- Custom event so click_scripts can force a refresh after connect/disconnect.
sbar.add("event", "bluetooth_update")

bluetooth:subscribe("bluetooth_update", function()
    update_bluetooth_status()
    if popup_open then
        rebuild_popup()
    end
end)

bluetooth:subscribe({ "forced", "routine", "system_woke" },
    update_bluetooth_status)

-- Fallback poll in case blueutil state changes aren't otherwise signalled.
-- sbar.exec callbacks only fire when the command exits, so an infinite
-- loop with a callback never runs; trigger the event instead.
sbar.exec("pkill -f 'sketchybar --trigger bluetooth_update'; "
    .. "while true; do sketchybar --trigger bluetooth_update; sleep 5; done &")

bluetooth:subscribe("mouse.clicked", toggle_details)
bluetooth:subscribe("mouse.exited.global", hide_details)

update_bluetooth_status()
