return function(Table: { [any]: any }, Callback: (i: any, v: any) -> any, Independant: boolean?)
	local NewTable = {}
	for i, v in Table do
		NewTable[Independant and #NewTable + 1 or i] = Callback(i, v)
	end
	return NewTable
end