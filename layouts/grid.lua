local M = {}
local utils = require("layouts.utils")

-- calculate windows per row given n windows
local function windows_per_rows(n)
	local retval = {}
	-- fill rows one by one until we cant fill it
	local nrows = math.ceil(math.sqrt(n))

	for i = 1, nrows do
		local windows_per_row = math.floor(n / nrows)
		if i <= n % nrows then
			windows_per_row = windows_per_row + 1
		end
		table.insert(retval, windows_per_row)
	end

	return retval
end

M.handle_layout = function(args)
	local retval = {}
	--
	local height_for_n = function(n)
		return utils.height_for_n(args, n)
	end
	local y_of_i = function(n, i)
		return utils.y_of_i(args, n, i)
	end
	local width_for_n = function(n)
		return utils.width_for_n(args, n)
	end
	local x_of_i = function(n, i)
		return utils.x_of_i(args, n, i)
	end
	--

	-- Let N be the number of windows
	-- N = 1 and N = 2 are special cases
	if args.count == 1 then
		if SMART_GAPS then
			table.insert(retval, { 0, 0, args.width, args.height })
		else
			table.insert(retval, { OUTER_GAPS, OUTER_GAPS, args.width - OUTER_GAPS * 2, args.height - OUTER_GAPS * 2 })
		end
	elseif args.count > 1 then
		local n = math.ceil(math.sqrt(args.count))

		if PREFER_HORIZONTAL then
			-- we prefer windows get max available horizontal space
			local windows_per_row = windows_per_rows(args.count)

			for i = 1, #windows_per_row do
				for j = 1, windows_per_row[i] do
					local x = x_of_i(windows_per_row[i], j)
					local y = y_of_i(n, i)
					local w = width_for_n(windows_per_row[i])
					local h = height_for_n(n)
					table.insert(retval, { x, y, w, h })
				end
			end
		else
			-- we prefer windows get max available vertical space
			local windows_per_column = windows_per_rows(args.count)

			for i = 1, #windows_per_column do
				for j = 1, windows_per_column[i] do
					local x = x_of_i(n, i)
					local y = y_of_i(windows_per_column[i], j)
					local w = width_for_n(n)
					local h = height_for_n(windows_per_column[i])
					table.insert(retval, { x, y, w, h })
				end
			end
		end
	end
	return retval
end

return M
