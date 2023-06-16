local M = {}
local utils = require("layouts.utils")

-- Layout for N windows
-- N = 2                       ---------------
-- ---------------             |   |     |   |            ---------------
-- |      |      |             | 2 |  1  | 3 |            | 2 |     | 3 |
-- |  1   |   2  |  - N = 4 ->  ---            - N = 7 -> | 4 |  1  | 5 |
-- |      |      |             |   |     |   |            | 6 |     | 7 |
-- ---------------             | 4 |     |   |            ---------------
--                             ---------------

M.handle_layout = function(args)
	local retval = {}

	--
	local height_for_n = function(n)
		return utils.height_for_n(args, n)
	end
	local y_of_i = function(n, i)
		return utils.y_of_i(args, n, i)
	end
	local revert = function(return_of_layout)
		return utils.revert(args, return_of_layout)
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
	elseif args.count <= 1 + MAIN_COUNT then
		local x, y, w, h
		local main_w = (args.width - OUTER_GAPS * 2 - INNER_GAPS) * MAIN_RATIO
		local main_h = height_for_n(math.min(MAIN_COUNT, args.count))
		local side_w = main_w * (1 / MAIN_RATIO - 1)
		-- main window(s)
		local w_accumulated = 0
		for i = 1, math.min(MAIN_COUNT, args.count) do
			if PREFER_HORIZONTAL then
				if args.count <= MAIN_COUNT then
					x = OUTER_GAPS
					w = args.width - OUTER_GAPS * 2
					h = main_h
					y = OUTER_GAPS + INNER_GAPS * (i - 1) + main_h * (i - 1)
				else
					x = OUTER_GAPS + side_w + INNER_GAPS
					x = 0
					w = main_w
					h = main_h
					y = y_of_i(MAIN_COUNT, i)
				end
			else
				if args.count <= MAIN_COUNT then
					local q = (i == 1) and 1 or (math.min(args.count) - 1)
					w = main_w / q
					w_accumulated = w_accumulated + w
					x = OUTER_GAPS + INNER_GAPS * (i - 1) + w_accumulated - w
					y = OUTER_GAPS
					h = args.height - OUTER_GAPS * 2
				else
					x = OUTER_GAPS + side_w + INNER_GAPS
					y = y_of_i(MAIN_COUNT, i)
					w = main_w
					h = main_h
				end
			end
			table.insert(retval, {
				x,
				y,
				w,
				h,
			})
		end

		-- side window
		for _ = MAIN_COUNT + 1, args.count do
			table.insert(retval, {
				OUTER_GAPS,
				OUTER_GAPS,
				side_w,
				args.height - OUTER_GAPS * 2,
			})
		end
	elseif args.count > 1 + MAIN_COUNT then
		-- general case
		local main_w = (args.width - 2 * OUTER_GAPS - 2 * INNER_GAPS) * MAIN_RATIO
		local main_h = height_for_n(MAIN_COUNT)
		local side_w = 0.5 * main_w * (1 / MAIN_RATIO - 1)
		-- main window(s)
		for i = 1, MAIN_COUNT do
			table.insert(retval, {
				OUTER_GAPS + side_w + INNER_GAPS,
				y_of_i(MAIN_COUNT, i),
				main_w,
				main_h,
			})
		end

		local nleft = math.ceil((args.count - MAIN_COUNT) / 2)
		local nright = args.count - MAIN_COUNT - nleft
		for i = MAIN_COUNT + 1, args.count do
			local isLeft = (i - MAIN_COUNT) % 2 == 1
			if isLeft then
				table.insert(retval, {
					OUTER_GAPS,
					y_of_i(nleft, (i - MAIN_COUNT + 1) / 2),
					side_w,
					height_for_n(nleft),
				})
			else
				table.insert(retval, {
					args.width - OUTER_GAPS - side_w,
					y_of_i(nright, (i - MAIN_COUNT) / 2),
					side_w,
					height_for_n(nright),
				})
			end
		end
	end

	if REVERSE then
		retval = revert(retval)
	end
	return retval
end

return M
