--[=[
    Owner: JustStop__
	Version: 0.0.1
    Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.roact)

return function(props, hooks)
	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.35, 0.525),
		BorderColor3 = Color3.fromHex("000000"),
		BackgroundColor3 = Color3.fromHex("ffffff"),
		BorderSizePixel = 0,
		Size = UDim2.fromScale(0.7, 0.92),
		BackgroundTransparency = 1,
	}, {
		Grid = Roact.createElement("UIGridLayout", {
			VerticalAlignment = 0,
			SortOrder = 2,
			CellSize = UDim2.fromScale(0.30, 0.39),
			FillDirectionMaxCells = 3,
			CellPadding = UDim2.fromScale(0.02, 0.04),
			HorizontalAlignment = 0,
		}),

		Roact.createFragment(props),
	})
end
