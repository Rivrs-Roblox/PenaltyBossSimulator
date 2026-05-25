--[=[
    Owner: JustStop__
	Version: 0.0.1
    Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.roact)
local RoactHooks = require(ReplicatedStorage.Packages.hooks)
local RoactSpring = require(ReplicatedStorage.Packages.RoactSpring)

local Components = StarterPlayerScripts.Client.Roact.Components
local Text = require(Components.Text)

-- Controllers
local StoreController = Knit.GetController("StoreController")
local DataCacheController = Knit.GetController("DataCacheController")
local UI = DataCacheController:GetFile("Images")

local function SubCardComp(props, hooks)
	setmetatable(props, {
		__index = {
			order = 1,
			name = "Jos Morningho",
			productName = "Jos Morningho",
			icon = "rbxassetid://132492458278010",
			flag = "Portugal",
			multiplier = 2,
			price = "you forgot",
		},
	})

	local styles, api = RoactSpring.useSpring(hooks, function()
		return { sizeAlpha = 1 }
	end)

	return Roact.createElement("Frame", {
		LayoutOrder = props.order,
		Position = UDim2.fromScale(0.02, 0.1),
		ClipsDescendants = true,
		BackgroundColor3 = Color3.fromHex("fff67c"),
		Size = styles.sizeAlpha:map(function(alpha)
			return UDim2.fromScale(0.46 * alpha, 0.895 * alpha)
		end),
		ZIndex = 2,
	}, {
		NameText = Roact.createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Font = Enum.Font.FredokaOne,
			Position = UDim2.fromScale(0.5, 0.1),
			Size = UDim2.fromScale(0.9, 0.15),
			Text = props.name,
			TextColor3 = Color3.fromHex("ffffff"),
			TextScaled = true,
			TextWrapped = true,
			ZIndex = 3,
		}, {
			UIStroke = Roact.createElement("UIStroke", {
				Color = Color3.fromHex("ffffff"),
				Thickness = 2,
			}, {
				UIGradient = Roact.createElement("UIGradient", {
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromHex("ff6326")),
						ColorSequenceKeypoint.new(1, Color3.fromHex("591b00")),
					}),
					Rotation = 90,
				}),
			}),
		}),

		Value = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromHex("ffffff"),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.7, 0.6),
			BorderColor3 = Color3.fromHex("000000"),
			ZIndex = 2,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(0.53, 0.22),
		}, {
			ValueText = Text({
				size = UDim2.fromScale(0.45, 0.65),
				position = UDim2.fromScale(0.761, 0.383),
				text = "x" .. (props.multiplier or 1),
				color = Color3.fromHex("ffd500"),
				index = 3,
				align = Enum.TextXAlignment.Center,
				stroke = 2,
				strokeColor = Color3.fromHex("313131"),
			}),

			Icon = Roact.createElement("ImageLabel", {
				LayoutOrder = 1,
				ScaleType = 3,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Image = UI.Money2,
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.849, 0.15),
				ZIndex = 10,
				BackgroundColor3 = Color3.fromHex("ffffff"),
				Size = UDim2.fromScale(1, 1),
			}, {
				Ratio = Roact.createElement("UIAspectRatioConstraint", {}),
			}),
			List = Roact.createElement("UIListLayout", {
				VerticalAlignment = 2,
				SortOrder = 2,
				HorizontalAlignment = 2,
				Padding = UDim.new(0.05, 0),
				ItemLineAlignment = 2,
				FillDirection = 0,
			}),
		}),

		UIStroke = Roact.createElement("UIStroke", { Color = Color3.fromHex("ffffff"), Thickness = 2 }, {
			UIGradient = Roact.createElement("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromHex("ff6326")),
					ColorSequenceKeypoint.new(1, Color3.fromHex("591b00")),
				}),
				Rotation = 90,
			}),
		}),
		UICorner = Roact.createElement("UICorner", { CornerRadius = UDim.new(0, 2) }),
		Ratio = Roact.createElement("UIAspectRatioConstraint", { AspectRatio = 1.61 }),

		Pic = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = Color3.fromHex("ffffff"),
			Position = UDim2.fromScale(0.05, 0.58),
			Size = UDim2.fromScale(0.75, 0.75),
			ZIndex = 2,
		}, {
			UIGradient = Roact.createElement("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromHex("ffcc00")),
					ColorSequenceKeypoint.new(1, Color3.fromHex("ff8239")),
				}),
				Rotation = 90,
			}),
			UIStroke = Roact.createElement("UIStroke", {
				Color = Color3.fromHex("7d4d15"),
				Thickness = 2,
			}),
			UICorner = Roact.createElement("UICorner", { CornerRadius = UDim.new(1, 0) }),
			Ratio = Roact.createElement("UIAspectRatioConstraint", {}),
			Icon = Roact.createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Image = props.icon,
				Position = UDim2.fromScale(0.5, 0.5),
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.fromScale(1, 1),
				ZIndex = 2,
			}, { Ratio = Roact.createElement("UIAspectRatioConstraint", {}) }),
			Sparkle = Roact.createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Image = UI.Sparkle,
				Position = UDim2.fromScale(0.5, 0.5),
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.fromScale(1.3, 1.3),
				ZIndex = 3,
			}, { Ratio = Roact.createElement("UIAspectRatioConstraint", {}) }),
		}),

		Flag = Roact.createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = UI[props.flag],
			Position = UDim2.fromScale(0.87, 0.32),
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromScale(0.3, 0.3),
			ZIndex = 3,
		}, { Ratio = Roact.createElement("UIAspectRatioConstraint", {}) }),

		Buy = Roact.createElement("ImageButton", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.7, 0.849),
			Size = UDim2.fromScale(0.53, 0.2),
			ZIndex = 8,
			ClipsDescendants = true,
			BackgroundColor3 = Color3.fromHex("ffffff"),
			[Roact.Event.MouseButton1Click] = function()
				StoreController:BuyItem({ name = props.productName })
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
			UICorner = Roact.createElement("UICorner", { CornerRadius = UDim.new(0, 2) }),
			UIStroke = Roact.createElement("UIStroke", { Color = Color3.fromHex("fcffc4"), Thickness = 2 }),
			UIGradient = Roact.createElement("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromHex("3dff27")),
					ColorSequenceKeypoint.new(1, Color3.fromHex("23a617")),
				}),
				Rotation = 90,
			}),
			PriceText = Text({
				text = props.price,
				color = Color3.fromHex("ffffff"),
				index = 9,
				size = UDim2.fromScale(0.85, 0.85),
				position = UDim2.fromScale(0.5, 0.5),
				stroke = 1.5,
				strokeColor = Color3.fromHex("313131"),
			}),
		}),
	})
end

return RoactHooks.new(Roact)(SubCardComp)
