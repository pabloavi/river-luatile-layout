-- TODO: add multi-monitor support
-- TODO: add grid layout
package.path = package.path .. ";" .. os.getenv("HOME") .. "/.config/river-luatile/?.lua"

OUTPUT_LAYOUTS = {}
-- output_layouts["DP-1"] = "centered"
-- output_layouts["DP-2"] = "bspwm"
OUTPUT_LAYOUTS["eDP-1"] = "centered"

-- read config
local config = require("config")

config.load({ "eDP-1" })

function handle_metadata(args)
	return { name = OUTPUT_LAYOUTS[args.output] }
end

function handle_layout(args)
	-- print(args.output)
	return layouts[OUTPUT_LAYOUTS[args.output]](args)
end

local gaps_alt = 0
function toggle_gaps()
	local tmp = GAPS
	GAPS = gaps_alt
	gaps_alt = tmp
end

-- Change output to a specific layout
function switch_layout(layout_name)
	local layout_names = {}
	for layout, _ in pairs(layouts) do
		table.insert(layout_names, layout)
	end
	if not layout_name or not layouts[layout_name] then
		return
	end

	-- TODO: add support for multiple outputs
	OUTPUT_LAYOUTS["eDP-1"] = layout_name
	config.load({ "eDP-1", OUTPUT_LAYOUTS["eDP-1"] })
	os.execute("notify-send 'RiverWM' 'Switched to layout " .. layout_name .. "'")
end

-- cycle through layouts
function cycle_layout(prev)
	-- TODO: add support for multiple outputs
	local current_layout = OUTPUT_LAYOUTS["eDP-1"]
	local next_layout = nil
	local prev_layout = nil
	local found = false

	local layout_names = {}
	for layout, _ in pairs(layouts) do
		table.insert(layout_names, layout)
	end

	-- go through all layouts and find the next one (latest cycles back to first)
	for i, layout in ipairs(layout_names) do
		if found then
			next_layout = layout
			break
		end
		if layout == current_layout then
			found = true
		end
		prev_layout = layout_names[i - 1] or layout_names[#layout_names]
	end

	-- if no next layout was found, use the first one
	if next_layout == nil then
		next_layout = layout_names[1]
	end

	if prev then
		OUTPUT_LAYOUTS["eDP-1"] = next_layout
	else
		OUTPUT_LAYOUTS["eDP-1"] = prev_layout
	end
	config.load({ "eDP-1", OUTPUT_LAYOUTS["eDP-1"] })
end

function list_layouts()
	local layout_names = {}
	for layout, _ in pairs(layouts) do
		table.insert(layout_names, layout)
	end
	-- order them alphabetically
	table.sort(layout_names)
	-- print to /tmp/river_layouts
	string = table.concat(layout_names, "\n")
	os.execute("echo '" .. string .. "' > /tmp/river_layouts")
end

layouts = {
	centered = require("layouts.centered").handle_layout,
	bspwm = require("layouts.bspwm"),
	rivertile_simple = require("layouts.rivertile_simple"),
	rivertile = require("layouts.rivertile").handle_layout,
	monocle = require("layouts.monocle"),
	grid = require("layouts.grid").handle_layout,
}

-- require functions from the layout file
-- print(output_layouts["eDP-1"])
-- require("layouts." .. output_layouts["eDP-1"])

-- EXTRA FUNCTIONS
function main_count_up()
	MAIN_COUNT = MAIN_COUNT + 1
end

function main_count_down()
	if MAIN_COUNT == 1 then
		return
	end
	MAIN_COUNT = MAIN_COUNT - 1
end

function main_ratio_up()
	if MAIN_RATIO >= 0.95 then
		return
	end
	MAIN_RATIO = MAIN_RATIO + 0.05
end

function main_ratio_down()
	if MAIN_RATIO <= 0.05 then
		return
	end
	MAIN_RATIO = MAIN_RATIO - 0.05
end

function main_ratio_reset()
	MAIN_RATIO = 0.5
end

function toggle_prefer_horizontal()
	PREFER_HORIZONTAL = not PREFER_HORIZONTAL
end
