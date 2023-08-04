local utils = require("config")
local config = utils.get_config().layout

-- EXTRA FUNCTIONS
-- TODO: deprecate
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

	OUTPUT_LAYOUTS[CMD_OUTPUT] = layout_name
	current_layout = layout_name
	utils.set_layout_options(config, CMD_OUTPUT, current_layout)
	utils.store_tags(CURRENT_TAGS, current_layout, CMD_OUTPUT)
	-- os.execute("notify-send 'RiverWM' 'Switched to layout " .. layout_name .. "'")
end

-- cycle through layouts
function cycle_layout(prev)
	local current_layout = OUTPUT_LAYOUTS[CMD_OUTPUT]
	local next_layout = nil
	local prev_layout = nil
	local found = false

	for i, layout in ipairs(layout_names) do
		if found then
			next_layout = layout
			prev_layout = layout_names[i - 2] or layout_names[#layout_names]
			break
		end
		if layout == current_layout then
			found = true
		end
	end

	if not next_layout then
		next_layout = layout_names[1]
	end
	if not prev_layout then
		prev_layout = layout_names[#layout_names - 1]
	end

	if prev then
		OUTPUT_LAYOUTS[CMD_OUTPUT] = prev_layout
	else
		OUTPUT_LAYOUTS[CMD_OUTPUT] = next_layout
	end
	utils.store_tags(CURRENT_TAGS, OUTPUT_LAYOUTS[CMD_OUTPUT], CMD_OUTPUT)
end

function list_layouts()
	-- print to /tmp/river_layouts
	string = table.concat(layout_names, "\n")
	os.execute("echo '" .. string .. "' > /tmp/river_layouts")
end

function main_count_up()
	OVERRIDEN_OPTIONS["MAIN_COUNT"] = MAIN_COUNT + 1
end

function main_count_down()
	if MAIN_COUNT == 1 then
		return
	end
	OVERRIDEN_OPTIONS["MAIN_COUNT"] = MAIN_COUNT - 1
end

function main_ratio_up()
	if MAIN_RATIO >= 0.95 then
		return
	end
	OVERRIDEN_OPTIONS["MAIN_RATIO"] = MAIN_RATIO + 0.05
end

function main_ratio_down()
	if MAIN_RATIO <= 0.05 then
		return
	end
	OVERRIDEN_OPTIONS["MAIN_RATIO"] = MAIN_RATIO - 0.05
end

function main_ratio_reset()
	OVERRIDEN_OPTIONS["MAIN_RATIO"] = 0.5
end

function toggle_prefer_horizontal()
	OVERRIDEN_OPTIONS["PREFER_HORIZONTAL"] = not PREFER_HORIZONTAL
end

-- TODO: add these to README.md
function toggle_prefer_right()
	OVERRIDEN_OPTIONS["PREFER_RIGHT"] = not PREFER_RIGHT
end

function toggle_reverse()
	OVERRIDEN_OPTIONS["REVERSE"] = not REVERSE
end

function gaps(inner, up)
	if inner == "inner" then
		inner = true
	else
		inner = false
	end
	if up == "up" then
		up = true
	else
		up = false
	end

	if inner then
		if up then
			OVERRIDEN_OPTIONS["INNER_GAPS"] = INNER_GAPS + 5
		else
			if INNER_GAPS < 5 then
				return
			end
			OVERRIDEN_OPTIONS["INNER_GAPS"] = INNER_GAPS - 5
		end
	else
		if up then
			OVERRIDEN_OPTIONS["OUTER_GAPS"] = OUTER_GAPS + 5
		else
			if OUTER_GAPS < 5 then
				return
			end
			OVERRIDEN_OPTIONS["OUTER_GAPS"] = OUTER_GAPS - 5
		end
	end
end

function location(direction)
	local vertical = false
	local dirs = { "left", "right", "top", "bottom" }
	if direction == "top" or direction == "bottom" then
		vertical = true
	end

	for _, dir in ipairs(dirs) do
		if dir == direction then
			if vertical then
				OVERRIDEN_OPTIONS["LOCATION_VERTICAL"] = dir
			else
				OVERRIDEN_OPTIONS["LOCATION_HORIZONTAL"] = dir
			end
			return
		end
	end
end
