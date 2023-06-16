local M = {}

M.handle_layout = function(args)
	local retval = {}

	for i = 0, (args.count - 1) do
		table.insert(retval, {
			GAPS + i * OFFSET,
			GAPS + i * OFFSET,
			(args.width - GAPS * 2) - (args.count - 1) * OFFSET,
			(args.height - GAPS * 2) - (args.count - 1) * OFFSET,
		})
	end

	return retval
end

return M
