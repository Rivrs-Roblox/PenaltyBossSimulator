--[=[
    Toggle Item Component
    Visual follows Applications/newSettings, functionality remains from Applications/Settings
]=]

-- Game services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Roact = require(ReplicatedStorage.Packages.roact)

local function makeToggleButton(params)
	local enabled = params.enabled == true
	local zIndex = params.zIndexBase or 5

	local strokeColor = if enabled then Color3.fromHex("26cf13") else Color3.fromHex("8f0000")
	local gradientA = if enabled then Color3.fromHex("1dd42c") else Color3.fromHex("ff362f")
	local gradientB = if enabled then Color3.fromHex("21681e") else Color3.fromHex("8d1414")
	local text = if enabled then "On" else "Off"

	return Roact.createElement("ImageButton", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.9, 0.5),
		Size = UDim2.fromScale(0.15, 0.6),
		BackgroundColor3 = Color3.fromHex("ffffff"),
		BorderSizePixel = 0,
		AutoButtonColor = true,
		LayoutOrder = 3,
		ZIndex = zIndex,
		[Roact.Event.MouseButton1Click] = params.onActivated,
	}, {
		UICorner = Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0, 6),
		}),

		UIStroke = Roact.createElement("UIStroke", {
			Color = strokeColor,
			Thickness = 2,
		}),

		UIGradient = Roact.createElement("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, gradientA),
				ColorSequenceKeypoint.new(1, gradientB),
			}),
			Rotation = 90,
		}),

		ButtonText = Roact.createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.85, 0.55),
			BackgroundTransparency = 1,
			Text = text,
			TextColor3 = Color3.fromHex("fafafa"),
			TextScaled = true,
			TextWrapped = true,
			FontFace = Font.fromName("Ubuntu", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
			ZIndex = zIndex + 1,
		}),
	})
end

return function(params: {})
	setmetatable(params, {
		__index = {
			Name = "" :: string,
			Icon = "rbxassetid://129162351030527" :: string,
			Value = true :: boolean,
			Action = function() end,
			hooks = nil,
			Order = 0 :: number,
			ZIndexBase = 3 :: number,
		},
	})

	local zIndex = params.ZIndexBase

	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromScale(1, 0.17),
		BackgroundColor3 = Color3.fromHex("000000"),
		BackgroundTransparency = 0.5,
		LayoutOrder = params.Order,
		ZIndex = zIndex,
	}, {
		UICorner = Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0, 2),
		}),

		UIStroke = Roact.createElement("UIStroke", {
			Color = Color3.fromHex("143758"),
			Thickness = 1.5,
		}),

		Main = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.fromScale(0.04, 0.5),
			Size = UDim2.fromScale(0.7, 0.35),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ZIndex = zIndex + 1,
		}, {
			Icon = Roact.createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.fromScale(0, 0.5),
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Image = params.Icon,
				ScaleType = Enum.ScaleType.Fit,
				ZIndex = zIndex + 1,
			}, {
				Ratio = Roact.createElement("UIAspectRatioConstraint", {}),
			}),

			NameText = Roact.createElement("TextLabel", {
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.fromScale(0.104, 0.5),
				Size = UDim2.fromScale(0.673, 1),
				BackgroundTransparency = 1,
				Text = params.Name,
				TextColor3 = Color3.fromHex("fafafa"),
				TextScaled = true,
				TextWrapped = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				FontFace = Font.fromName("Ubuntu", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
				ZIndex = zIndex + 2,
			}),
		}),

		Toggle = makeToggleButton({
			enabled = params.Value,
			onActivated = params.Action,
			zIndexBase = zIndex + 2,
		}),
	})
end
