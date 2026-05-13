return function (name: string, table: table)
	local id2 = 0
	for id, data in pairs(table) do
		if data.Name == name then
			id2 = id
			break
		end
	end
	return id2
end