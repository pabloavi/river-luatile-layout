local M = {}

local outer_gap = GAPS / 2
local inner_gap = GAPS / 2
local location_horizontal = "left"
local location_vertical = "top"
local count = 0

--- Layout generator
--@param args: table{width, height, count, tags}
M.handle_layout = function(args)
	local layout = {}

	local windows = math.min(MAIN_COUNT, args.count)
	if args.count == 1 then
		if SMART_GAPS then
			table.insert(layout, { 0, 0, args.width, args.height })
		else
			table.insert(layout, { GAPS, GAPS, args.width - GAPS * 2, args.height - GAPS * 2 })
		end
	elseif args.count <= windows then
		local main_w = (args.width - GAPS * 2)
		local side_w = (args.width - GAPS * 3) - main_w
		local main_h = args.height - GAPS * 2
		local side_h = (args.height - GAPS) / (args.count - 1) - GAPS
		-- given n windows on a side, return the height of each window
		local function height_for_n(n)
			return (args.height - GAPS * (n + 1)) / n
		end

		-- given n windows on a side, return the height of i-th window
		local function y_of_i(n, i)
			return GAPS * i + height_for_n(n) * (i - 1)
		end

		for i = 1, windows do
			table.insert(layout, {
				GAPS,
				y_of_i(windows, i),
				main_w,
				height_for_n(windows),
			})
		end
	else
		count = args.count
		local secondary_count = args.count - MAIN_COUNT
		local usable_width, usable_height
		local location

		-- check whether monitor is vertical or horizontal
		if args.width > args.height then
			location = location_horizontal
		else
			location = location_vertical
		end

		if location == "left" or location == "right" then
			usable_width = args.width - (2 * outer_gap)
			usable_height = args.height - (2 * outer_gap)
		else
			usable_width = args.height - (2 * outer_gap)
			usable_height = args.width - (2 * outer_gap)
		end

		local main_width, main_height, main_height_rem
		local secondary_width, secondary_heigth, secondary_height_rem

		-- layout creation
		if MAIN_COUNT > 0 and secondary_count > 0 then
			main_width = MAIN_RATIO * usable_width
			main_height = usable_height / MAIN_COUNT
			main_height_rem = math.fmod(usable_height, MAIN_COUNT)
			secondary_width = usable_width - main_width
			secondary_heigth = usable_height / secondary_count
			secondary_height_rem = math.fmod(usable_height, secondary_count)
		elseif MAIN_COUNT > 0 then
			main_width = usable_width
			main_height = usable_height / MAIN_COUNT
			main_height_rem = math.fmod(usable_height, MAIN_COUNT)
		elseif secondary_width > 0 then
			main_width = 0
			secondary_width = usable_width
			secondary_heigth = usable_height / secondary_count
			secondary_height_rem = math.fmod(usable_height, secondary_count)
		end

		-- set x, y, w, h
		for i = 0, (args.count - 1) do
			local x, y, width, height

			if i < MAIN_COUNT then
				x = 0
				y = (i * main_height) + (i > 0 and { main_height_rem } or { 0 })[1]
				width = main_width
				height = main_height + (i == 0 and { main_height_rem } or { 0 })[1]
			else
				x = main_width
				y = (i - MAIN_COUNT) * secondary_heigth + (i > MAIN_COUNT and { secondary_height_rem } or { 0 })[1]
				width = secondary_width
				height = secondary_heigth + (i == MAIN_COUNT and { secondary_height_rem } or { 0 })[1]
			end

			x = x + inner_gap
			y = y + inner_gap
			width = width - (2 * inner_gap)
			height = height - (2 * inner_gap)

			-- set depending on location
			if location == "left" then
				table.insert(layout, {
					x + outer_gap,
					y + outer_gap,
					width,
					height,
				})
			elseif location == "right" then
				table.insert(layout, {
					usable_width - width - x + outer_gap,
					y + outer_gap,
					width,
					height,
				})
			elseif location == "top" then
				table.insert(layout, {
					y + outer_gap,
					x + outer_gap,
					height,
					width,
				})
			else
				table.insert(layout, {
					y + outer_gap,
					usable_width - width - x + outer_gap,
					height,
					width,
				})
			end
		end
	end

	return layout
end

M.flip = function()
	for _ = 0, count do
		os.execute("riverctl swap next")
	end
	os.execute("riverctl focus-view previous")
end

return M
