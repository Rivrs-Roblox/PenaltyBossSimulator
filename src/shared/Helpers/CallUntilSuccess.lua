return function(f: (any) -> any, ...: any): any
	local x
	while task.wait() do
		local success, result = pcall(f, ...)
		if success then
			x = result
			break
		end
	end
	return x
end