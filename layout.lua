package.path = package.path .. ";" .. os.getenv("HOME") .. "/.config/river-luatile/?.lua"

OUTPUT_LAYOUTS = {}
local CMD_OUTPUT = "eDP-1" -- TODO: get rid of this
local config = require("config")
config.load({ "eDP-1" })

layouts = {}
for layout in
	io.popen(
		[[ls -1 ]] .. os.getenv("HOME") .. [[/.config/river-luatile/layouts | grep -E ".*\.lua$" | sed -e "s/\.lua$//"]]
	)
		:lines()
do
	if layout ~= "utils" then
		layouts[layout] = require("layouts." .. layout).handle_layout
	end
end

layout_names = {}
for layout, _ in pairs(layouts) do
	table.insert(layout_names, layout)
end
table.sort(layout_names)

function handle_metadata(args)
	return { name = OUTPUT_LAYOUTS[args.output] }
end

function handle_layout(args)
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

	OUTPUT_LAYOUTS[CMD_OUTPUT] = layout_name
	config.load({ CMD_OUTPUT, OUTPUT_LAYOUTS["eDP-1"] })
	os.execute("notify-send 'RiverWM' 'Switched to layout " .. layout_name .. "'")
end

-- cycle through layouts
function cycle_layout(prev)
	local current_layout = OUTPUT_LAYOUTS[CMD_OUTPUT]
	local next_layout = nil
	local prev_layout = nil
	local found = false

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
		OUTPUT_LAYOUTS[CMD_OUTPUT] = next_layout
	else
		OUTPUT_LAYOUTS[CMD_OUTPUT] = prev_layout
	end
	config.load({ CMD_OUTPUT, OUTPUT_LAYOUTS[CMD_OUTPUT] })
end

function list_layouts()
	-- print to /tmp/river_layouts
	string = table.concat(layout_names, "\n")
	os.execute("echo '" .. string .. "' > /tmp/river_layouts")
end

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
