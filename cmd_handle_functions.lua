local M = {}
-- TODO: move these functions to own module
M.flip = function(args, prev)
	if not prev then
		for _ = 0, args.count do
			os.execute("riverctl swap next")
		end
		os.execute("riverctl focus-view previous")
	else
		for _ = 0, args.count do
			os.execute("riverctl swap previous")
		end
		os.execute("riverctl focus-view next")
	end
end

M.bring_to_front = function(args)
	if OUTPUT_LAYOUTS[args.output] ~= "tabbed" then
		return
	end
	os.execute("riverctl zoom")
	os.execute("riverctl swap next")
end

return M
