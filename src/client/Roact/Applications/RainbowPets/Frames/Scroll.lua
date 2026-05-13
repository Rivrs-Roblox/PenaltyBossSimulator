--[=[
	Owner: JustStop__
	Version: v0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Roact = require(ReplicatedStorage.Packages.roact)

-- Scroll
return function(params: table)
	setmetatable(params, {
		__index = {
			children = {},
		},
	})

	local children = {
		UIPadding = Roact.createElement("UIPadding", {
			PaddingTop = UDim.new(0.01, 0),
			PaddingBottom = UDim.new(0.03, 0),
		}),

		Grid = Roact.createElement("UIGridLayout", {
			CellPadding = UDim2.fromScale(0.03, 0.01),
			CellSize = UDim2.fromScale(0.15, 0.4),
			FillDirection = Enum.FillDirection.Horizontal,
			FillDirectionMaxCells = 5,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Top,
		}),
	}

	for key, child in pairs(params.children) do
		children[key] = child
	end

	for index = 1, 10 do
		children["BottomSpacer_" .. index] = Roact.createElement("Frame", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = 999000 + index,
			ZIndex = 3,
		})
	end

	return Roact.createElement("ScrollingFrame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.fromScale(0, 0),
		ClipsDescendants = true,
		ElasticBehavior = Enum.ElasticBehavior.WhenScrollable,
		Position = UDim2.fromScale(0.5, 0.501),
		ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0),
		ScrollBarImageTransparency = 0.32,
		ScrollBarThickness = 8,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		Size = UDim2.fromScale(0.95, 0.685),
		ZIndex = 3,
	}, children)
end