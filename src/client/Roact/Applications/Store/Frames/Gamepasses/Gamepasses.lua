--[=[
    Owner: JustStop__
	Version: 0.0.1
    Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Roact = require(ReplicatedStorage.Packages.roact)

-- Gamepasses
return function(props, items: table)
	setmetatable(props, {
		__index = {
			order = 4,
		},
	})

	return Roact.createElement("Frame", {
		LayoutOrder = props.order,
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 3.8),
		-- AutomaticSize = Enum.AutomaticSize.Y,
	}, {
		Grid = Roact.createElement("UIGridLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			CellSize = UDim2.fromScale(0.47, 0.125),
			FillDirectionMaxCells = 2,
			CellPadding = UDim2.fromScale(0.02, 0.015),
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
		}),
		Roact.createFragment(items),
	})
end
