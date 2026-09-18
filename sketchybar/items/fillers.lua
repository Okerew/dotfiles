-- Workaround for macOS 27: a mouse-down on the bar area not covered by any
-- item breaks item rendering until a reload. Clicks landing inside an item's
-- hit box are fine, so we cover the empty gap with two invisible items.
-- See FelixKratz/SketchyBar#850

local left_candidates = { "front_app", "menu.15" }
local right_candidates = {
    "widgets.ram",
    "widgets.bluetooth",
    "widgets.wifi",
    "widgets.volume1",
    "calendar",
    "media.play",
    "media.info",
}

local function make_filler(name)
    return sbar.add("item", name, {
        width = 0,
        padding_left = 0,
        padding_right = 0,
        icon = { string = "" },
        label = { string = "" },
        background = { drawing = false },
    })
end

local left_filler = make_filler("filler.left")
local right_filler = make_filler("filler.right")

local function first_rect(result)
    if not result or not result.bounding_rects then
        return nil
    end
    for _, rect in pairs(result.bounding_rects) do
        return rect
    end
end

local function item_end(name)
    local rect = first_rect(sbar.query(name))
    if rect and rect.size[1] > 0 then
        return rect.origin[1] + rect.size[1]
    end
    return 0
end

local function update_gap()
    local left_end = 0
    for _, name in ipairs(left_candidates) do
        local e = item_end(name)
        if e > left_end then
            left_end = e
        end
    end

    local right_start = nil
    for _, name in ipairs(right_candidates) do
        local rect = first_rect(sbar.query(name))
        if rect and rect.size[1] > 0 then
            local x = rect.origin[1]
            if not right_start or x < right_start then
                right_start = x
            end
        end
    end

    if right_start and right_start > left_end then
        local gap = right_start - left_end
        left_filler:set({ width = math.floor(gap * 0.6) })
        right_filler:set({ width = math.floor(gap * 0.5) })
    else
        left_filler:set({ width = 0 })
        right_filler:set({ width = 0 })
    end
end

local watcher = sbar.add("item", {
    drawing = false,
    updates = true,
})

watcher:subscribe("routine", update_gap)
watcher:subscribe("space_change", update_gap)
watcher:subscribe("front_app_switched", update_gap)
