local M = {}

M.handle_layout = function(args)
	local retval = {}

	for i = 0, (args.count - 1) do
		table.insert(retval, {
			OUTER_GAPS + i * OFFSET,
			OUTER_GAPS + i * OFFSET,
			(args.width - OUTER_GAPS * 2) - (args.count - 1) * OFFSET,
			(args.height - OUTER_GAPS * 2) - (args.count - 1) * OFFSET,
		})
	end

	return retval
end

return M
