local M = {}

M.load = function(args)
	local monitor = args[1]
	local layout = args[2]
	-- we are also receiving layout because this function may also be called to change layout,
	-- and we would need to know which layout to load
	local fallback = {
		MAIN_RATIO = 0.5,
		GAPS = 10, -- TODO: deprecate
		INNER_GAPS = 10,
		OUTER_GAPS = 10,
		SMART_GAPS = true,
		MAIN_COUNT = 2,
		PREFER_HORIZONTAL = false,
		REVERSE = false,
	}
	-- convert all values in fallback to globals
	for k, v in pairs(fallback) do
		_G[k] = v
	end

	-- parse config file
	local json = require("json")
	local file = io.open(os.getenv("HOME") .. "/.config/river/layout.json", "r")
	if not file then
		return
	end
	local config
	config = json.decode(file:read("*all"))
	file:close()

	-- convert all values in default to globals
	local default_config = config["default"]
	for k, v in pairs(default_config) do
		_G[k] = v
	end

	-- if layout is given, use it; else, use the layout from the config
	local monitor_config = config[monitor]
	if not monitor_config then
		return
	end
	layout = layout or monitor_config["layout"] or default_config["layout"] or "centered"

	-- overwrite default config with monitor config
	if monitor_config["override"][layout] then
		for k, v in pairs(monitor_config["override"][layout]) do
			_G[k] = v
		end
	end
	OUTPUT_LAYOUTS[monitor] = layout
end

return M
