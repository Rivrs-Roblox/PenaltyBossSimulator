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
			text = "You forgot the text...",
			color = Color3.fromRGB(0, 0, 0),
			position = UDim2.fromScale(0.5, 0.5),
			size = UDim2.fromScale(1, 1),
			textSize = 14,
			textScaled = true,
			stroke = 0,
			strokeColor = Color3.fromRGB(25, 25, 25),
			index = 1,
			transparency = 0,
			rotation = 0,
			gradientRotation = 0,
			align = Enum.TextXAlignment.Center,
			alignY = Enum.TextYAlignment.Center,
			order = 0,
			visible = true,
			font = Font.new("rbxasset://fonts/families/FredokaOne.json"),
			children = {},
			Offset = Vector2.new(0,0),
			scale = 1,
		},
	})
	return Roact.createElement("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		TextTransparency = params.transparency,
		Position = params.position,
		Text = params.text,
		Size = params.size,
		TextColor3 = params.color,
		TextScaled = params.textScaled,
		TextSize = params.textSize,
		TextXAlignment = params.align,
		TextYAlignment = params.alignY,
		Rotation = params.rotation,
		ZIndex = params.index,
		Visible = params.visible,
		LayoutOrder = params.order,
		FontFace = params.font,
	}, {
		Stroke({ thick = params.stroke, color = params.strokeColor }),
		Gradient = Roact.createElement("UIGradient", {
			Color = params.gradient,
			Rotation = params.gradientRotation,
			Offset = params.Offset
		}),
		Roact.createFragment(params.children),
	})
end
