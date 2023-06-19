package.path = package.path .. ";" .. os.getenv("HOME") .. "/.config/river-luatile/?.lua"

-- SET STARTING VALUES. WILL BE OVERWRITTEN
CURRENT_TAGS = 1
OUTPUT_LAYOUTS = {}
local CMD_OUTPUT = "eDP-1" -- TODO: get rid of this
local config = require("config")
config.load({ monitor = "eDP-1", tags = CURRENT_TAGS }) -- NOTE: just to have a default

if not REMEMBER then
	config.write_tags_from_config()
end

-- GET LAYOUTS FROM ./layouts/
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

-- LAYOUT IMPLEMENTATION
function handle_metadata(args)
	return { name = OUTPUT_LAYOUTS[args.output] }
end

function handle_layout(args)
	CURRENT_TAGS = args.tags -- export tags to global

	function flip(prev)
		if not prev then
			for _ = 0, args.count do
				os.execute("riverctl swap next")
			end
			os.execute("riverctl focus-view previous")
		else
			for _ = 0, args.count do
				os.execute("riverctl swap previous")
			end
			os.execute("riverctl focus-view next")
		end
	end

	config.load({ monitor = args.output, layout = config.get_tags(CURRENT_TAGS, args.output), tags = CURRENT_TAGS })
	config.store_tags(CURRENT_TAGS, OUTPUT_LAYOUTS[args.output], args.output)

	return layouts[OUTPUT_LAYOUTS[args.output]](args)
end

-- EXTRA FUNCTIONS
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
	config.store_tags(CURRENT_TAGS, OUTPUT_LAYOUTS[CMD_OUTPUT], CMD_OUTPUT)
	config.load({ monitor = CMD_OUTPUT, layout = config.get_tags(CURRENT_TAGS, CMD_OUTPUT), tags = CURRENT_TAGS })
	os.execute("notify-send 'RiverWM' 'Switched to layout " .. layout_name .. "'")
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
	config.store_tags(CURRENT_TAGS, OUTPUT_LAYOUTS[CMD_OUTPUT], CMD_OUTPUT)
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

-- TODO: add these to README.md
function toggle_prefer_right()
	PREFER_RIGHT = not PREFER_RIGHT
end

function toggle_reverse()
	REVERSE = not REVERSE
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
			INNER_GAPS = INNER_GAPS + 5
		else
			if INNER_GAPS < 5 then
				return
			end
			INNER_GAPS = INNER_GAPS - 5
		end
	else
		if up then
			OUTER_GAPS = OUTER_GAPS + 5
		else
			if OUTER_GAPS < 5 then
				return
			end
			OUTER_GAPS = OUTER_GAPS - 5
		end
	end
end
