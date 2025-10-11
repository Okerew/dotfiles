local colors = require("colors")
local settings = require("settings")

-- Execute the event provider binary which provides the event "cpu_update" for
-- the cpu load data, which is fired every 2.0 seconds.
sbar.exec("killall cpu_load >/dev/null; $CONFIG_DIR/helpers/event_providers/cpu_load/bin/cpu_load cpu_update 2.0")

-- Execute RAM monitoring
sbar.exec("killall ram_load >/dev/null; $CONFIG_DIR/helpers/event_providers/ram_load/bin/ram_load ram_update 2.0")

local cpu = sbar.add("graph", "widgets.cpu", 42, {
	position = "right",
	graph = { color = colors.blue },
	background = {
		height = 22,
		color = { alpha = 0 },
		border_color = { alpha = 0 },
		drawing = true,
	},
	label = {
		string = "cpu ??%",
		font = {
			family = settings.font.numbers,
			style = settings.font.style_map["Bold"],
			size = 9.0,
		},
		align = "right",
		padding_right = 0,
		width = 0,
		y_offset = 4,
	},
	padding_right = settings.paddings + 6,
})

local ram = sbar.add("graph", "widgets.ram", 42, {
	position = "right",
	graph = { color = colors.green },
	background = {
		height = 22,
		color = { alpha = 0 },
		border_color = { alpha = 0 },
		drawing = true,
	},
	label = {
		string = "ram ??%",
		font = {
			family = settings.font.numbers,
			style = settings.font.style_map["Bold"],
			size = 9.0,
		},
		align = "right",
		padding_right = 0,
		width = 0,
		y_offset = 4,
	},
	padding_right = settings.paddings + 6,
})

cpu:subscribe("cpu_update", function(env)
	-- Also available: env.user_load, env.sys_load
	local load = tonumber(env.total_load)
	cpu:push({ load / 100. })
	local color = colors.blue
	if load > 30 then
		if load < 60 then
			color = colors.yellow
		elseif load < 80 then
			color = colors.orange
		else
			color = colors.red
		end
	end
	cpu:set({
		graph = { color = color },
		label = "cpu " .. env.total_load .. "%",
	})
end)

ram:subscribe("ram_update", function(env)
	local usage = tonumber(env.ram_usage)
	ram:push({ usage / 100. })
	local color = colors.green
	if usage > 30 then
		if usage < 60 then
			color = colors.yellow
		elseif usage < 80 then
			color = colors.orange
		else
			color = colors.red
		end
	end
	ram:set({
		graph = { color = color },
		label = "ram " .. env.ram_usage .. "%",
	})
end)

cpu:subscribe("mouse.clicked", function(env)
	sbar.exec("open -a 'Activity Monitor'")
end)

ram:subscribe("mouse.clicked", function(env)
	sbar.exec("open -a 'Activity Monitor'")
end)

-- Background around the cpu and ram items
sbar.add("bracket", "widgets.system.bracket", { ram.name, cpu.name }, {
	background = { color = colors.bg1 },
})

-- Background around the system items
sbar.add("item", "widgets.system.padding", {
	position = "right",
	width = settings.group_paddings,
})
