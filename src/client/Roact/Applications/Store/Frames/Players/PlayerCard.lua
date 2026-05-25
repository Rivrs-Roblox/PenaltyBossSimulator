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

local function MainCardComp(props, hooks)
	setmetatable(props, {
		__index = {
			order = 1,
			name = "Ronaldinyo",
			productName = "Ronaldinyo",
			icon = "rbxassetid://106686223694310",
			price = "you forgot",
			multiplier = 2,
			flag = "Brazil",
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
			return UDim2.fromScale(0.91 * alpha, 0.91 * alpha)
		end),
		ZIndex = 2,
	}, {
		Pic = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.fromScale(0, 0.55),
			BorderColor3 = Color3.fromHex("000000"),
			BackgroundColor3 = Color3.fromHex("ffffff"),
			BorderSizePixel = 0,
			Size = UDim2.fromScale(0.65, 0.65),
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
			UICorner = Roact.createElement("UICorner", {
				CornerRadius = UDim.new(1, 0),
			}),
			Ratio = Roact.createElement("UIAspectRatioConstraint", {}),
			Icon = Roact.createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				ScaleType = Enum.ScaleType.Fit,
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.5),
				BackgroundColor3 = Color3.fromHex("ffffff"),
				ZIndex = 2,
				Image = props.icon,
				Size = UDim2.fromScale(1, 1),
			}, { Ratio = Roact.createElement("UIAspectRatioConstraint", {}) }),
			Sparkle = Roact.createElement("ImageLabel", {
				ScaleType = Enum.ScaleType.Fit,
				BorderColor3 = Color3.fromHex("000000"),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Image = UI.Sparkle,
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.5),
				BackgroundColor3 = Color3.fromHex("ffffff"),
				ZIndex = 3,
				BorderSizePixel = 0,
				Size = UDim2.fromScale(1.3, 1.3),
			}, { Ratio = Roact.createElement("UIAspectRatioConstraint", {}) }),
		}),
		Flag = props.flag and Roact.createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			ScaleType = Enum.ScaleType.Fit,
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.84, 0.6),
			BackgroundColor3 = Color3.fromHex("ffffff"),
			ZIndex = 2,
			Image = UI[props.flag] or UI.Roblox_Flag,
			Size = UDim2.fromScale(0.25, 0.25),
		}, { Ratio = Roact.createElement("UIAspectRatioConstraint", {}) }),
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
		NameText = Text({
			text = props.name,
			anchorPoint = Vector2.new(0.5, 0.5),
			position = UDim2.fromScale(0.5, 0.1),
			size = UDim2.fromScale(0.9, 0.15),
			color = Color3.fromHex("ffffff"),
			index = 3,
			children = {
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
			},
		}),
		Value = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromHex("ffffff"),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.7, 0.28),
			BorderColor3 = Color3.fromHex("000000"),
			ZIndex = 2,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(0.53, 0.22),
		}, {
			ValueText = Text({
				text = "x" .. (props.multiplier or 1),
				anchorPoint = Vector2.new(0.5, 0.5),
				position = UDim2.fromScale(0.761, 0.383),
				size = UDim2.fromScale(0.45, 0.65),
				color = Color3.fromHex("ffd500"),
				index = 3,
				align = Enum.TextXAlignment.Right,
				alignY = Enum.TextYAlignment.Center,
				stroke = 2,
				strokeColor = Color3.fromHex("313131"),
			}),
			Icon = Roact.createElement("ImageLabel", {
				LayoutOrder = 1,
				ScaleType = Enum.ScaleType.Fit,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Image = UI.Wins,
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.849, 0.15),
				ZIndex = 10,
				BackgroundColor3 = Color3.fromHex("ffffff"),
				Size = UDim2.fromScale(1, 1),
			}, { Ratio = Roact.createElement("UIAspectRatioConstraint", {}) }),
			List = Roact.createElement("UIListLayout", {
				VerticalAlignment = Enum.VerticalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				Padding = UDim.new(0.05, 0),
				FillDirection = Enum.FillDirection.Horizontal,
			}),
		}),
		Ratio = Roact.createElement("UIAspectRatioConstraint", {}),
		UICorner = Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0, 2),
		}),
		Buy = Roact.createElement("ImageButton", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.7, 0.849),
			Size = UDim2.fromScale(0.53, 0.2),
			ZIndex = 3,
			ClipsDescendants = true,
			BackgroundColor3 = Color3.fromHex("ffffff"),
			[Roact.Event.Activated] = function()
				StoreController:BuyItem({ name = props.productName })
			end,
			[Roact.Event.MouseEnter] = function()
				api.start({ sizeAlpha = 1.02 })
			end,
			[Roact.Event.MouseLeave] = function()
				api.start({ sizeAlpha = 1 })
			end,
			[Roact.Event.MouseButton1Down] = function()
				api.start({ sizeAlpha = 0.98 })
			end,
			[Roact.Event.MouseButton1Up] = function()
				api.start({ sizeAlpha = 1.02 })
			end,
		}, {
			UICorner = Roact.createElement("UICorner", {
				CornerRadius = UDim.new(0, 2),
			}),
			UIStroke = Roact.createElement("UIStroke", {
				Color = Color3.fromHex("fcffc4"),
				Thickness = 2,
			}),
			PriceText = Text({
				text = props.price,
				anchorPoint = Vector2.new(0.5, 0.5),
				position = UDim2.fromScale(0.5, 0.5),
				size = UDim2.fromScale(0.85, 0.85),
				color = Color3.fromHex("ffffff"),
				index = 3,
				stroke = 1.5,
				strokeColor = Color3.fromHex("313131"),
			}),
			UIGradient = Roact.createElement("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromHex("3dff27")),
					ColorSequenceKeypoint.new(1, Color3.fromHex("23a617")),
				}),
				Rotation = 90,
			}),
		}),
	})
end

return RoactHooks.new(Roact)(MainCardComp)
