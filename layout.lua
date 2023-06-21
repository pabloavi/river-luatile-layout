package.path = package.path .. ";" .. os.getenv("HOME") .. "/.config/river-luatile/?.lua"

-- SET STARTING VALUES. WILL BE OVERWRITTEN
TAGS_PATH = os.getenv("HOME") .. "/.config/river/scripts/tmp/river_tags"
CURRENT_TAGS = 1
OUTPUT_LAYOUTS = {}
OVERRIDEN_OPTIONS = {}
local CMD_OUTPUT = "eDP-1"

local utils = require("config")
local config = utils.get_config().layout
local current_layout = utils.get_layout_from_tagfile(CURRENT_TAGS, CMD_OUTPUT)
	or config[CMD_OUTPUT]["layout"]
	or config["default"]["layout"]
	or "centered"

utils.set_layout_options(config, "eDP-1", current_layout)
OUTPUT_LAYOUTS[CMD_OUTPUT] = current_layout

if not REMEMBER then
	utils.write_tags_from_config()
end

-- TODO: improve this
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

	-- TODO: move these functions to own module
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

	function bring_to_front()
		if OUTPUT_LAYOUTS[args.output] ~= "tabbed" then
			return
		end
		os.execute("riverctl zoom")
		os.execute("riverctl swap next")
	end

	current_layout = utils.get_layout_from_tagfile(CURRENT_TAGS, CMD_OUTPUT)
		or config[CMD_OUTPUT]["layout"]
		or config["default"]["layout"]
		or "centered"

	utils.set_layout_options(config, args.output, current_layout)
	utils.store_tags(CURRENT_TAGS, current_layout, args.output)

	return layouts[OUTPUT_LAYOUTS[args.output]](args)
end

require("cmd_functions")
