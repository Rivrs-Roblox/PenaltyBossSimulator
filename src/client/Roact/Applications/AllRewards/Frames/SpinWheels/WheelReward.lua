local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Roact = require(ReplicatedStorage.Packages.roact)

return function(params)
	params = params or {}

	local data = params.data or {}
	local position = params.position or UDim2.fromScale(0.5, 0.2)
	local rotation = params.rotation or 0
	local zIndex = params.zIndex or 9

	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Position = position,
		Rotation = rotation,
		Size = params.size or UDim2.fromScale(0.24, 0.24),
		ZIndex = zIndex,
	}, {
		PercentText = Roact.createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			FontFace = Font.fromName("Ubuntu", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
			Position = UDim2.fromScale(0.5, 0.09),
			Size = UDim2.fromScale(0.95, 0.18),
			Text = data.percent or "",
			TextColor3 = Color3.fromHex("ffffff"),
			TextScaled = true,
			TextWrapped = true,
			ZIndex = zIndex + 1,
		}, {
			UIStroke = Roact.createElement("UIStroke", {
				Color = Color3.fromHex("191919"),
				Thickness = 1.5,
			}),
		}),

		NameText = Roact.createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			FontFace = Font.fromName("Ubuntu", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
			Position = UDim2.fromScale(0.5, 0.315),
			Size = UDim2.fromScale(1.15, 0.2),
			Text = data.name or "",
			TextColor3 = data.nameColor or Color3.fromHex("ffd60b"),
			TextScaled = true,
			TextWrapped = true,
			ZIndex = zIndex + 1,
		}, {
			UIStroke = Roact.createElement("UIStroke", {
				Color = Color3.fromHex("191919"),
				Thickness = 1.5,
			}),
		}),

		AmountText = Roact.createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			FontFace = Font.fromName("Ubuntu", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
			Position = UDim2.fromScale(0.5, 1.24),
			Size = UDim2.fromScale(0.9, 0.25),
			Text = data.amount or "",
			TextColor3 = Color3.fromHex("ffffff"),
			TextScaled = true,
			TextWrapped = true,
			ZIndex = zIndex + 1,
		}, {
			UIStroke = Roact.createElement("UIStroke", {
				Color = Color3.fromHex("191919"),
				Thickness = 1.5,
			}),
		}),

		Icon = Roact.createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = data.image or "",
			Position = UDim2.fromScale(0.5, 0.72),
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromScale(0.65, 0.65),
			Visible = data.image ~= nil and data.image ~= "",
			ZIndex = zIndex + 1,
		}),
	})
end
