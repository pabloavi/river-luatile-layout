-- TODO: fix INNER_GAPS when OUTER_GAPS = 0 and more windows than MAIN_COUNT
local M = {}

local utils = require("layouts.utils")

local count = 0
local OUTER_GAPS = OUTER_GAPS / 2
local INNER_GAPS = INNER_GAPS / 2

--- Layout generator
--@param args: table{width, height, count, tags}
M.handle_layout = function(args)
	local layout = {}

	--
	local height_for_n = function(n)
		return utils.height_for_n(args, n)
	end
	local y_of_i = function(n, i)
		return utils.y_of_i(args, n, i)
	end
	--

	local windows = math.min(MAIN_COUNT, args.count)
	if args.count == 1 then
		if SMART_GAPS then
			table.insert(layout, { 0, 0, args.width, args.height })
		else
			table.insert(
				layout,
				{ 2 * OUTER_GAPS, 2 * OUTER_GAPS, args.width - 2 * OUTER_GAPS * 2, args.height - 2 * OUTER_GAPS * 2 }
			)
		end
	elseif args.count <= windows then
		local main_w = (args.width - OUTER_GAPS * 2)
		for i = 1, windows do
			table.insert(layout, {
				OUTER_GAPS,
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
			location = LOCATION_HORIZONTAL
		else
			location = LOCATION_VERTICAL
		end

		if location == "left" or location == "right" then
			usable_width = args.width - (2 * OUTER_GAPS)
			usable_height = args.height - (2 * OUTER_GAPS)
		else
			usable_width = args.height - (2 * OUTER_GAPS)
			usable_height = args.width - (2 * OUTER_GAPS)
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

			x = x + INNER_GAPS
			y = y + INNER_GAPS
			width = width - (2 * INNER_GAPS)
			height = height - (2 * INNER_GAPS)

			-- set depending on location
			if location == "left" then
				table.insert(layout, {
					x + OUTER_GAPS,
					y + OUTER_GAPS,
					width,
					height,
				})
			elseif location == "right" then
				table.insert(layout, {
					usable_width - width - x + OUTER_GAPS,
					y + OUTER_GAPS,
					width,
					height,
				})
			elseif location == "top" then
				table.insert(layout, {
					y + OUTER_GAPS,
					x + OUTER_GAPS,
					height,
					width,
				})
			else
				table.insert(layout, {
					y + OUTER_GAPS,
					usable_width - width - x + OUTER_GAPS,
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
