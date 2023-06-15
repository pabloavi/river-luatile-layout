local M = {}

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
	-- Let N be the number of windows
	-- N = 1 and N = 2 are special cases
	if args.count == 1 then
		if SMART_GAPS then
			table.insert(retval, { 0, 0, args.width, args.height })
		else
			table.insert(retval, { GAPS, GAPS, args.width - GAPS * 2, args.height - GAPS * 2 })
		end
	elseif args.count > 1 then
		local function height_for_n(n)
			-- given n windows on a side, return the height of each window
			return (args.height - GAPS * (n + 1)) / n
		end

		local function y_of_i(n, i)
			-- given n windows on a side, return the height of i-th window
			return GAPS * i + height_for_n(n) * (i - 1)
		end

		local function width_for_n(n)
			-- given n windows on a row, return the width of each window
			return (args.width - GAPS * (n + 1)) / n
		end

		local function x_of_i(n, i)
			-- given n windows on a row, return the x position of i-th window
			return GAPS * i + width_for_n(n) * (i - 1)
		end
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
