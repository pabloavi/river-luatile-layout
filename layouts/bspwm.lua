local M = {}
M.handle_layout = function(args)
	--
	local revert = function(retval)
		return require("layouts.utils").revert(args, retval)
	end
	--

	local retval = {}
	if args.count == 1 then
		if SMART_GAPS then
			table.insert(retval, { 0, 0, args.width, args.height })
		else
			table.insert(retval, { GAPS, GAPS, args.width - GAPS * 2, args.height - GAPS * 2 })
		end
	elseif args.count > 1 then
		local main_w = (args.width - GAPS * 3) * MAIN_RATIO
		local main_h = args.height - GAPS * 2
		table.insert(retval, {
			GAPS,
			GAPS,
			main_w,
			main_h,
		})
		-- we are doing a dwindle layout here. first window is the biggest, the rest are smaller
		for i = 2, args.count do
			local w, h, x, y
			local isEven = i % 2 == 0
			local isOdd = not isEven
			-- width:
			-- if it is even, its width is previous window's width * (1/ratio - 1)
			-- if it is odd, its width depends on:
			-- it is the last: width = previous window's width
			-- it is not the last: width = (previous window's width - gaps ) * ratio
			if isEven then
				w = retval[i - 1][3] * (1 / MAIN_RATIO - 1)
			else
				if i == args.count then
					w = retval[i - 1][3]
				else
					w = (retval[i - 1][3] - GAPS) * MAIN_RATIO
				end
			end

			-- height:
			-- if is the second window (i == 2) it depends on:
			-- it is the last window: h = previous window's height
			-- it is not the last window: h = (main_h - 3 * gaps) * ratio
			-- otherwise:
			-- if it is odd, h = previous window's height * (1/ratio - 1)
			-- if it is even, it depends on:
			-- it is the last: h = previous window's height
			-- it is not the last: h = (previous window's height - gaps) * ratio
			if i == 2 then
				if i == args.count then
					h = retval[i - 1][4]
				else
					h = (args.height - 3 * GAPS) * MAIN_RATIO
				end
			else
				if isOdd then
					h = retval[i - 1][4] * (1 / MAIN_RATIO - 1)
				else
					if i == args.count then
						h = retval[i - 1][4]
					else
						h = (retval[i - 1][4] - GAPS) * MAIN_RATIO
					end
				end
			end

			-- x:
			-- if it is even, x = previous window's x + previous window's width + gaps
			-- if it is odd, x = previous window's x
			if isEven then
				x = retval[i - 1][1] + retval[i - 1][3] + GAPS
			else
				x = retval[i - 1][1]
			end

			-- y:
			-- if it is even, y = previous window's y
			-- if it is odd, y = previous window's y + previous window's height + gaps
			if isEven then
				y = retval[i - 1][2]
			else
				y = retval[i - 1][2] + retval[i - 1][4] + GAPS
			end

			table.insert(retval, {
				x,
				y,
				w,
				h,
			})
		end
	end

	if REVERSE then
		retval = revert(retval)
	end

	return retval
end

return M
