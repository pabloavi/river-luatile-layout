local M = {}

M.handle_layout = function(args)
	local retval = {}
	PREFER_RIGHT = false

	if args.count == 1 then
		if SMART_GAPS then
			table.insert(retval, { 0, 0, args.width, args.height })
		else
			table.insert(retval, { GAPS, GAPS, args.width - GAPS * 2, args.height - GAPS * 2 })
		end
	elseif args.count > 1 then
		local main_w = (args.width - GAPS * 3) * MAIN_RATIO
		local side_w = (args.width - GAPS * 3) * (1 - MAIN_RATIO)

		local x
		if PREFER_RIGHT then
			x = GAPS + main_w * (1 / MAIN_RATIO - 1)
		else
			x = GAPS
		end

		table.insert(retval, {
			x,
			GAPS,
			main_w,
			args.height - GAPS * 2,
		})

		for i = 1, (args.count - 1) do
			if PREFER_RIGHT then
				x = GAPS
			else
				x = 2 * GAPS + main_w
			end
			table.insert(retval, {
				x,
				GAPS + (i - 1) * OFFSET,
				side_w - GAPS,
				(args.height - GAPS * 2) - (args.count - 2) * OFFSET,
			})
		end
	end
	return retval
end

return M
