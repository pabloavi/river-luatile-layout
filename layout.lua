package.path = package.path .. ";" .. os.getenv("HOME") .. "/.config/river-luatile/?.lua"

-- SET STARTING VALUES. WILL BE OVERWRITTEN
TAGS_PATH = os.getenv("HOME") .. "/.config/river/scripts/tmp/river_tags"
CURRENT_TAGS = 1
OUTPUT_LAYOUTS = {}
OVERRIDEN_OPTIONS = {}
local CMD_OUTPUT = "eDP-1"

local utils = require("config")
local config = utils.get_config().layout
local current_layout = utils.get_current_layout(config, CURRENT_TAGS, CMD_OUTPUT)
utils.set_layout_options(config, "eDP-1", current_layout)
OUTPUT_LAYOUTS[CMD_OUTPUT] = current_layout

if not REMEMBER then
	utils.write_tags_from_config()
end

layouts = {}
layout_names = utils.get_available_layouts()

local fn = require("cmd_handle_functions") -- extra functions that require args

-- LAYOUT IMPLEMENTATION
function handle_metadata(args)
	return { name = OUTPUT_LAYOUTS[args.output] }
end

function handle_layout(args)
	CURRENT_TAGS = args.tags -- export tags to global

  -- stylua: ignore
	function bring_to_front() return fn.bring_to_front(args) end
  -- stylua: ignore
	function flip(prev) return fn.flip(args, prev) end

	current_layout = utils.get_current_layout(config, CURRENT_TAGS, CMD_OUTPUT)
	utils.set_layout_options(config, args.output, current_layout)
	utils.store_tags(CURRENT_TAGS, current_layout, args.output)
	OUTPUT_LAYOUTS[CMD_OUTPUT] = current_layout

	return layouts[OUTPUT_LAYOUTS[args.output]](args)
end

require("cmd_functions") -- load functions that don't require args
