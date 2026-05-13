local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Roact = require(ReplicatedStorage.Packages.roact)

local DEFAULT_STROKE = Color3.fromHex("191919")

return function(params)
	params = params or {}

	local gradient = params.gradient or {
		ColorSequenceKeypoint.new(0, Color3.fromHex("3f91fc")),
		ColorSequenceKeypoint.new(1, Color3.fromHex("234fad")),
	}

	return Roact.createElement("ImageButton", {
		LayoutOrder = params.layoutOrder or 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromHex("fcf9ff"),
		BorderSizePixel = 0,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = params.size or UDim2.fromScale(0.3, 1),
		ZIndex = params.zIndex or 20,
		[Roact.Event.MouseButton1Click] = params.onClick,
	}, {
		UIGradient = Roact.createElement("UIGradient", {
			Color = ColorSequence.new(gradient),
			Rotation = 90,
		}),

		UICorner = Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0, 6),
		}),

		UIStroke = Roact.createElement("UIStroke", {
			Color = params.strokeColor or Color3.fromHex("2ad1ff"),
			Thickness = 2,
		}),

		ValueText = Roact.createElement("TextLabel", {
			AnchorPoint = params.price and Vector2.new(0, 0.5) or Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			FontFace = Font.fromName("Ubuntu", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
			Position = params.price and UDim2.fromScale(0.05, 0.5) or UDim2.fromScale(0.5, 0.5),
			Size = params.price and UDim2.fromScale(0.5, 0.7) or UDim2.fromScale(0.82, 0.7),
			Text = params.text or "Button",
			TextColor3 = Color3.fromHex("ffffff"),
			TextScaled = true,
			TextWrapped = true,
			TextXAlignment = params.price and Enum.TextXAlignment.Left or Enum.TextXAlignment.Center,
			ZIndex = (params.zIndex or 20) + 1,
		}, {
			UIStroke = Roact.createElement("UIStroke", {
				Color = params.textStrokeColor or DEFAULT_STROKE,
				Thickness = 1.5,
			}),
		}),

		PriceText = params.price and Roact.createElement("TextLabel", {
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundTransparency = 1,
			FontFace = Font.fromName("Ubuntu", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
			Position = UDim2.fromScale(0.95, 0.5),
			Size = UDim2.fromScale(0.5, 0.7),
			Text = params.price,
			TextColor3 = Color3.fromHex("ffffff"),
			TextScaled = true,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Right,
			ZIndex = (params.zIndex or 20) + 1,
		}, {
			UIStroke = Roact.createElement("UIStroke", {
				Color = params.textStrokeColor or DEFAULT_STROKE,
				Thickness = 1.5,
			}),
		}) or nil,

		Notification = params.showNotification and Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromHex("ff1d1d"),
			Position = UDim2.fromScale(0.95, 0.1),
			Size = UDim2.fromScale(0.6, 0.6),
			ZIndex = (params.zIndex or 20) + 5,
		}, {
			AspectRatio = Roact.createElement("UIAspectRatioConstraint"),
			Corner = Roact.createElement("UICorner", { CornerRadius = UDim.new(1, 0) }),
			UIStroke = Roact.createElement("UIStroke", { Color = Color3.fromHex("ffffff"), Thickness = 2 }),
			Icon = Roact.createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Image = "rbxassetid://113219014430159",
				Position = UDim2.fromScale(0.5, 0.5),
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.fromScale(0.8, 0.8),
				ZIndex = (params.zIndex or 20) + 6,
			}),
		}) or nil,
	})
end
