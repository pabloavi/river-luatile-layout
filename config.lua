local M = {}

---Load the config file and set the global variables.
---If no layout is given, the layout from the config file will be used.
---If a layout is given, it has priority.
---@param args table
M.load = function(args)
	local monitor = args.monitor
	local layout = args.layout
	-- we are also receiving layout because this function may also be called to change layout,
	-- and we would need to know which layout to load
	local fallback = {
		MAIN_RATIO = 0.5,
		GAPS = 10, -- TODO: deprecate
		INNER_GAPS = 10,
		OUTER_GAPS = 10,
		SMART_GAPS = true,
		MAIN_COUNT = 2,
		OFFSET = 20,
		PREFER_HORIZONTAL = false,
		REVERSE = false,
	}
	-- convert all values in fallback to globals
	for k, v in pairs(fallback) do
		_G[k] = v
	end

	-- parse config file
	local json = require("json")
	local file = io.open(os.getenv("HOME") .. "/.config/river/config.json", "r")
	if not file then
		return
	end
	local config
	config = json.decode(file:read("*all"))
	file:close()

	-- convert all values in default to globals
	local default_config = config["layout"]["default"]
	for k, v in pairs(default_config) do
		_G[k] = v
	end

	-- if layout is given, use it; else, use the layout from the config
	local monitor_config = config["layout"][monitor]
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

	-- tags variables
	local tags_fallback = {
		TAGS_PATH = "/tmp/river_tags",
	}
	TAGS_PATH = config["tags"]["TAGS_PATH"]:gsub("~", os.getenv("HOME")) or tags_fallback["TAGS_PATH"]
	REMEMBER = config["tags"]["REMEMBER"]

	OUTPUT_LAYOUTS[monitor] = layout
end

---Store the layout for a given tag and monitor.
---@param tags number
---@param layout string
---@param monitor string
M.store_tags = function(tags, layout, monitor)
	local file = io.open(TAGS_PATH, "r")
	if not file then
		return
	end
	local lines = {}
	for line in file:lines() do
		table.insert(lines, line)
	end

	-- check if current tag is inside the file
	local found = false
	for i, line in ipairs(lines) do
		local line_tag = tonumber(line:match("%d+"))
		if line_tag == tags then
			lines[i] = tags .. " " .. layout .. " " .. monitor
			found = true
			break
		end
	end
	if not found then
		table.insert(lines, tags .. " " .. layout .. " " .. monitor)
	end

	file = io.open(TAGS_PATH, "w")
	if not file then
		return
	end

	for _, line in ipairs(lines) do
		file:write(line .. "\n")
	end

	file:close()
end

---Get the layout for a given tag and monitor.
---@param tags number
---@param monitor string
---@return string|nil
M.get_tags = function(tags, monitor)
	local file = io.open(TAGS_PATH, "r")
	if not file then
		return
	end
	for line in file:lines() do
		-- allow underscores
		local line_tag, line_layout, line_monitor = line:match("(%d+) ([%w_]+) ([%w-]+)")
		if tonumber(line_tag) == tags and line_monitor == monitor then
			return line_layout
		end
	end
	return nil
end

---Empty the tags file.
M.clear_tags = function()
	local file = io.open(TAGS_PATH, "w")
	if not file then
		return
	end
	file:close()
end

---Write the tags from the config file to the tags file.
---If a tag starts with "i", it will be treated as the index of the tag.
M.write_tags_from_config = function()
	local json = require("json")
	local file = io.open(os.getenv("HOME") .. "/.config/river/config.json", "r")
	if not file then
		return
	end
	local config = json.decode(file:read("*all"))
	file:close()

	local tags = config["tags"]
	if not tags then
		return
	end

	local file = io.open(TAGS_PATH, "w")
	if not file then
		return
	end

	---Check if a string starts with a given substring.
	local begins_with = function(str, start)
		return str:sub(1, #start) == start
	end

	for monitor, _ in pairs(tags) do
		if monitor == "REMEMBER" or monitor == "TAGS_PATH" then
			goto continue
		end
		print(monitor)
		for tag, layout in pairs(tags[monitor]) do
			if begins_with(tag, "i") then
				tag = tonumber(2 ^ (tonumber(tag:sub(2)) - 1))
			end
			file:write(tag .. " " .. layout .. " " .. monitor .. "\n")
		end
		::continue::
	end
end

return M
