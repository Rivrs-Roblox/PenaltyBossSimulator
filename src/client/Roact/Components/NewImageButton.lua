local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Roact = require(ReplicatedStorage.Packages.roact)
local RoactSpring = require(ReplicatedStorage.Packages.RoactSpring)
local Sound = require(ReplicatedStorage.Packages.Sound)

return function(props, hooks)
	setmetatable(props, {
		__index = {
			size = UDim2.fromScale(0.32, 1),
		},
	})

	local styles, api = RoactSpring.useSpring(hooks, function()
		return {
			sizeAlpha = 1,
		}
	end)

	return Roact.createElement("ImageButton", {
		LayoutOrder = props.layoutOrder,
		Size = styles.sizeAlpha:map(function(alpha)
			return UDim2.new(
				props.size.X.Scale * alpha,
				props.size.X.Offset,
				props.size.Y.Scale * alpha,
				props.size.Y.Offset
			)
		end),
		Position = props.position or UDim2.fromScale(0.5, 0.5),
		BorderColor3 = Color3.fromHex("000000"),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BorderSizePixel = 0,
		BackgroundColor3 = props.color or Color3.fromHex("ffffff"),
		ZIndex = 2,

		[Roact.Event.MouseButton1Click] = function()
			if props.onClick then
				props.onClick()
			end
			Sound:PlaySound("UI_Click")
		end,
		[Roact.Event.MouseEnter] = function()
			api.start({ sizeAlpha = 1.05 })
		end,
		[Roact.Event.MouseLeave] = function()
			api.start({ sizeAlpha = 1 })
		end,
		[Roact.Event.MouseButton1Down] = function()
			api.start({ sizeAlpha = 0.95 })
		end,
		[Roact.Event.MouseButton1Up] = function()
			api.start({ sizeAlpha = 1.05 })
		end,
	}, {
		UICorner = Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0, 6),
		}),
		PriceText = Roact.createElement("TextLabel", {
			TextWrapped = true,
			TextColor3 = Color3.fromHex("ffffff"),
			Text = props.price or "",
			AnchorPoint = Vector2.new(1, 0.5),
			Font = Enum.Font.FredokaOne,
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Right,
			TextScaled = true,
			Position = UDim2.fromScale(0.95, 0.5),
			TextSize = 14,
			Size = UDim2.fromScale(0.5, 0.5),
			ZIndex = 2,
		}, {
			UIStroke = Roact.createElement("UIStroke", {
				Color = props.priceStroke or Color3.fromHex("000000"),
				Thickness = 2,
			}),
		}),
		ButtonText = Roact.createElement("TextLabel", {
			TextWrapped = true,
			TextColor3 = Color3.fromHex("fafafa"),
			Text = props.text or "",
			TextScaled = true,
			AnchorPoint = Vector2.new(0, 0.5),
			Font = Enum.Font.FredokaOne,
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.fromScale(0.05, 0.5),
			ZIndex = 5,
			TextSize = 14,
			Size = UDim2.fromScale(0.5, 0.5),
		}, {
			UIStroke = Roact.createElement("UIStroke", {
				Color = props.textStroke or Color3.fromHex("000000"),
				Thickness = 2,
			}),
		}),
	})
end
