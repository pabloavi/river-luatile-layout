local function handle_layout(args)
	local retval = {}
	if args.count == 1 then
		if SMART_GAPS then
			table.insert(retval, { 0, 0, args.width, args.height })
		else
			table.insert(retval, { GAPS, GAPS, args.width - GAPS * 2, args.height - GAPS * 2 })
		end
	elseif args.count > 1 then
		local main_w = (args.width - GAPS * 3) * MAIN_RATIO
		local side_w = (args.width - GAPS * 3) - main_w
		local main_h = args.height - GAPS * 2
		local side_h = (args.height - GAPS) / (args.count - 1) - GAPS
		table.insert(retval, {
			GAPS,
			GAPS,
			main_w,
			main_h,
		})
		for i = 0, (args.count - 2) do
			table.insert(retval, {
				main_w + GAPS * 2,
				GAPS + i * (side_h + GAPS),
				side_w,
				side_h,
			})
		end
	end
	return retval
end

return handle_layout
