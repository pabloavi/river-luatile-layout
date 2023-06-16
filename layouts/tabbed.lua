local M = {}

M.handle_layout = function(args)
	local retval = {}

	if args.count == 1 then
		if SMART_GAPS then
			table.insert(retval, { 0, 0, args.width, args.height })
		else
			table.insert(retval, { OUTER_GAPS, OUTER_GAPS, args.width - OUTER_GAPS * 2, args.height - OUTER_GAPS * 2 })
		end
	elseif args.count > 1 then
		local main_w = (args.width - 2 * OUTER_GAPS - INNER_GAPS) * MAIN_RATIO
		local side_w = (args.width - 2 * OUTER_GAPS - INNER_GAPS) * (1 - MAIN_RATIO)

		local x
		if PREFER_RIGHT then
			x = OUTER_GAPS + main_w * (1 / MAIN_RATIO - 1)
		else
			x = OUTER_GAPS
		end

		table.insert(retval, {
			x,
			OUTER_GAPS,
			main_w,
			args.height - OUTER_GAPS * 2,
		})

		for i = 1, (args.count - 1) do
			if PREFER_RIGHT then
				x = OUTER_GAPS
			else
				x = OUTER_GAPS + main_w + INNER_GAPS
			end
			table.insert(retval, {
				x,
				OUTER_GAPS + (i - 1) * OFFSET,
				side_w - OUTER_GAPS,
				(args.height - OUTER_GAPS * 2) - (args.count - 2) * OFFSET,
			})
		end
	end
	return retval
end

return M
