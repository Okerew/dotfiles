local is_dark_mode = function()
	local handle = io.popen("defaults read -g AppleInterfaceStyle 2>/dev/null")
	local result = handle:read("*a")
	handle:close()
	return result:match("Dark") ~= nil
end

local current_dark_mode = is_dark_mode()

local function start_simple_monitor()
	os.execute([[
        (
            while true; do
                sleep 2
                current_theme=$(defaults read -g AppleInterfaceStyle 2>/dev/null | grep -c "Dark")
                marker_file="$HOME/.config/sketchybar/.theme_state"
                
                if [ ! -f "$marker_file" ] || [ "$current_theme" != "$(cat "$marker_file" 2>/dev/null)" ]; then
                    echo "$current_theme" > "$marker_file"
                    sketchybar --reload
                fi
            done
        ) &
    ]])
end

start_simple_monitor()

local dark = current_dark_mode

return {
	black = dark and 0xff4a556a or 0xffe2e2e3,
	white = dark and 0xffe2e2e3 or 0xff4a556a,
	red = 0xfffc5d7c,
	green = 0xff9ed072,
	blue = 0xff76cce0,
	yellow = 0xffe7c664,
	orange = 0xfff39660,
	magenta = 0xffb39df3,
	grey = 0xff7f8490,
	transparent = 0x00000000,
	bar = {
		bg = dark and 0xff2e3440 or 0xffeceff4,
		border = dark and 0xffc0c4c8 or 0xff4c566a,
	},
	popup = {
		bg = dark and 0xc02c2e34 or 0xc0e5e9f0,
		border = dark and 0xffc0c4c8 or 0xff4c566a,
	},
	bg1 = dark and 0xff363944 or 0xffd8dee9,
	bg2 = dark and 0xff414550 or 0xffeceff4,
	with_alpha = function(color, alpha)
		if alpha > 1.0 or alpha < 0.0 then
			return color
		end
		return (color & 0x00ffffff) | (math.floor(alpha * 255.0) << 24)
	end,
}
