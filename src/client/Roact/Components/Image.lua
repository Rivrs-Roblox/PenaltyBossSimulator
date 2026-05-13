--[=[
    Owner: JustStop__
	Version: 0.0.1
    Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Roact = require(ReplicatedStorage.Packages.roact)

-- Components
local Stroke = require(script.Parent.Stroke)

return function(params: table)
	setmetatable(params, {
		__index = {
			image = "",
			transparency = 0,
			color = Color3.fromRGB(0, 0, 0),
			position = UDim2.fromScale(0.5, 0.5),
			size = UDim2.fromScale(1, 1),
			stroke = 0,
			backgroundTransparency = 0,
			backgroundColor = Color3.fromRGB(255, 255, 255),
			visible = true,
			rotation = 0,
			index = 1,
			order = 0,
			children = {},
		},
	})

	return Roact.createElement("ImageLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = params.backgroundTransparency,
		BackgroundColor3 = params.backgroundColor,
		Position = params.position,
		Image = params.image,
		Size = params.size,
		ZIndex = params.index,
		Visible = params.visible,
		Rotation = params.rotation,
		ScaleType = Enum.ScaleType.Fit,
		ImageTransparency = params.transparency,
		LayoutOrder = params.order,
	}, {
		UIStroke = Stroke({ thick = params.stroke }),

		Children = Roact.createFragment(params.children),
	})
end
