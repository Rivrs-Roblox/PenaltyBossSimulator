--[=[
    Owner: JustStop__
	Version: 0.0.1
    Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts

-- Packages
local Roact = require(ReplicatedStorage.Packages.roact)

-- Components
local Components = StarterPlayerScripts.Client.Roact.Components
local Grid = require(Components.Grid)

-- Featured
return function(items: table)
	return Roact.createElement("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(2.5, 1),
		LayoutOrder = 2,
		AutomaticSize = Enum.AutomaticSize.X,
	}, {
		Grid = Grid({
			cellPadding = UDim2.fromScale(0.01, 0.045),
			fillDirection = Enum.FillDirection.Vertical,
			horizontalAlignment = Enum.HorizontalAlignment.Left,
			verticalAlignment = Enum.VerticalAlignment.Top,
			startCorner = Enum.StartCorner.TopLeft,
			cellSize = UDim2.fromScale(0.134, 0.45),
		}),
		Roact.createFragment(items),
	})
end
