local M = {}

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
M.get_layout_from_tagfile = function(tags, monitor)
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
		for tag, layout in pairs(tags[monitor]) do
			if begins_with(tag, "i") then
				tag = tonumber(2 ^ (tonumber(tag:sub(2)) - 1))
			end
			file:write(tag .. " " .. layout .. " " .. monitor .. "\n")
		end
		::continue::
	end
end

--NEW METHOD
---Read the config file and store all the information in a single big table for each monitor and layout.
M.get_config = function()
	local json = require("json")
	local file = io.open(os.getenv("HOME") .. "/.config/river/config.json", "r")
	if not file then
		return
	end

	local config = json.decode(file:read("*all"))
	file:close()
	return config
end

---Given a layout, return a table with its options.
---@param config table the "layout" field of the config file
---@param monitor string the monitor name
---@param layout string the layout name
M.get_layout_options = function(config, monitor, layout)
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
		LOCATION_VERTICAL = "top",
		LOCATION_HORIZONTAL = "left",
	}

	local layout_table = {}
	for k, v in pairs(fallback) do
		layout_table[k] = v
	end

	local defaults = config["default"]
	local override = config[monitor]["override"][layout]

	for k, v in pairs(defaults) do
		layout_table[k] = v
	end

	if override then
		for k, v in pairs(override) do
			layout_table[k] = v
		end
	end

	return layout_table
end

---Set the layout options as global variables.
---@param config table the "layout" field of the config file
---@param monitor string the monitor name
---@param layout string the layout name
M.set_layout_options = function(config, monitor, layout)
	local layout_table = M.get_layout_options(config, monitor, layout)

	for k, v in pairs(layout_table) do
		_G[k] = v
	end

	for k, v in pairs(OVERRIDEN_OPTIONS) do
		_G[k] = v
	end
end

---Returns the layout for a given tag and monitor and config.
---@param config table the "layout" field of the config file
---@param tags number
---@param monitor string
---@return string
M.get_current_layout = function(config, tags, monitor)
	return M.get_layout_from_tagfile(tags, monitor)
		or config[monitor]["layout"]
		or config["default"]["layout"]
		or "centered"
end

---TODO: improve this function
---Returns the layout names in alphabetical order
---and sets the global variable "layouts" with the
---handle_layout function of each layout.
M.get_available_layouts = function()
	for layout in
		io.popen(
			[[ls -1 ]]
				.. os.getenv("HOME")
				.. [[/.config/river-luatile/layouts | grep -E ".*\.lua$" | sed -e "s/\.lua$//"]]
		):lines()
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
	return layout_names
end

return M
