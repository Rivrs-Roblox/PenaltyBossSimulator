local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.roact)

local DataCacheController = Knit.GetController("DataCacheController")
local Template = DataCacheController:GetFile("Template")
local MonetizationController = Knit.GetController("MonetizationController")
local StoreController = Knit.GetController("StoreController")

local Eggs = DataCacheController:GetFile("Eggs")
local UI = DataCacheController:GetFile("Images")

local Showcase = require(script.Parent.Showcase)

local StarterPlayerScripts = StarterPlayer.StarterPlayerScripts
local Components = StarterPlayerScripts.Client.Roact.Components
local Text = require(Components.Text)

return function(props)
	setmetatable(props, {
		__index = {
			eggId = props.eggId or "DefaultEgg",
			name = props.name or "Default Egg",
			icon = props.icon or "rbxassetid://0",
			product1 = props.product1 or "DefaultEgg",
			product3 = props.product3 or "DefaultEgg",
			product8 = props.product8 or "DefaultEgg",
			price1 = props.price1 or "0",
			price3 = props.price3 or "0",
			price8 = props.price8 or "0",
		},
	})

	local eggData = Eggs[props.eggId]

	return Roact.createElement("Frame", {
		LayoutOrder = props.order,
		ClipsDescendants = true,
		BackgroundColor3 = Color3.fromHex("ffffff"),
		Size = UDim2.fromScale(0.95, 0.5),
	}, {
		Showcase = Showcase({
			hooks = props.hooks,
			eggData = eggData,
		}),
		UICorner = Roact.createElement("UICorner", {}),
		Effect = Roact.createElement("ImageLabel", {
			ImageColor3 = Color3.fromHex("ffee00"),
			Image = "rbxassetid://106335669168445",
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.147, 0.64),
			BackgroundColor3 = Color3.fromHex("ffffff"),
			AnchorPoint = Vector2.new(0.5, 0.5),
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromScale(0.635, 1.795),
		}, { Ratio = Roact.createElement("UIAspectRatioConstraint", {}) }),
		Sparkle = Roact.createElement("ImageLabel", {
			ScaleType = Enum.ScaleType.Fit,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Image = UI.Sparkle,
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.15, 0.5),
			ZIndex = 3,
			Size = UDim2.fromScale(1, 1),
		}, { Ratio = Roact.createElement("UIAspectRatioConstraint", {}) }),
		Item = Roact.createElement("ImageLabel", {
			ScaleType = Enum.ScaleType.Fit,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Image = props.icon,
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.15, 0.5),
			ZIndex = 2,
			Size = UDim2.fromScale(1, 1),
		}, { Ratio = Roact.createElement("UIAspectRatioConstraint", {}) }),
		Ratio = Roact.createElement("UIAspectRatioConstraint", {
			AspectRatio = 3,
		}),
		NameText = Text({
			order = 1,
			text = props.name,
			color = Color3.fromHex("ffffff"),
			anchorPoint = Vector2.new(1, 0),
			align = Enum.TextXAlignment.Right,
			position = UDim2.fromScale(0.98, 0.05),
			index = 5,
			size = UDim2.fromScale(0.5, 0.12),
		}),
		UIStroke = Roact.createElement("UIStroke", {
			Color = Color3.fromHex("ffffff"),
			Thickness = 3,
		}, {
			UIGradient = Roact.createElement("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromHex("3442ff")),
					ColorSequenceKeypoint.new(1, Color3.fromHex("dd2528")),
				}),
				Rotation = -90,
			}),
		}),
		UIGradient = Roact.createElement("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromHex("5a39ff")),
				ColorSequenceKeypoint.new(1, Color3.fromHex("dd0004")),
			}),
			Rotation = 90,
		}),
		Buttons = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundColor3 = Color3.fromHex("ffffff"),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.646, 0.96),
			BorderColor3 = Color3.fromHex("000000"),
			ZIndex = 4,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(0.67, 0.17),
		}, {
			Buy = Roact.createElement("ImageButton", {
				LayoutOrder = 1,
				Position = UDim2.fromScale(0.26, 0.82),
				Size = UDim2.fromScale(0.3, 1),
				ZIndex = 2,
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = Color3.fromHex("ffba81"),
				[Roact.Event.Activated] = function()
					StoreController:BuyItem({ name = props.product1 })
				end,
			}, {
				UICorner = Roact.createElement("UICorner", {}),
				UIStroke = Roact.createElement("UIStroke", {
					Color = Color3.fromHex("ffe149"),
					Thickness = 2,
				}),
				PriceText = Text({
					text = `x1 - {Template.Messages.Robux_Icon}{MonetizationController:GetPrice(props.product1) or props.price1}`,
					color = Color3.fromHex("ffffff"),
					anchorPoint = Vector2.new(0.5, 0.5),
					position = UDim2.fromScale(0.5, 0.5),
					index = 3,
					size = UDim2.fromScale(0.8, 0.6),
					stroke = 1.5,
					strokeColor = Color3.fromHex("a3690c"),
				}),
			}),
			Buy3 = Roact.createElement("ImageButton", {
				LayoutOrder = 2,
				Position = UDim2.fromScale(0.26, 0.82),
				Size = UDim2.fromScale(0.3, 1),
				ZIndex = 2,
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = Color3.fromHex("ffc73a"),
				[Roact.Event.Activated] = function()
					StoreController:BuyItem({ name = props.product3 })
				end,
			}, {
				UICorner = Roact.createElement("UICorner", {}),
				UIStroke = Roact.createElement("UIStroke", {
					Color = Color3.fromHex("fff569"),
					Thickness = 2,
				}),
				PriceText = Text({
					text = `x3 - {Template.Messages.Robux_Icon}{MonetizationController:GetPrice(props.product3) or props.price3}`,
					color = Color3.fromHex("ffffff"),
					anchorPoint = Vector2.new(0.5, 0.5),
					position = UDim2.fromScale(0.5, 0.5),
					index = 3,
					size = UDim2.fromScale(0.8, 0.6),
					stroke = 1.5,
					strokeColor = Color3.fromHex("a3690c"),
				}),
			}),
			Buy8 = Roact.createElement("ImageButton", {
				LayoutOrder = 3,
				Position = UDim2.fromScale(0.26, 0.82),
				Size = UDim2.fromScale(0.3, 1),
				ZIndex = 2,
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = Color3.fromHex("ff7b23"),
				[Roact.Event.Activated] = function()
					StoreController:BuyItem({ name = props.product8 })
				end,
			}, {
				UICorner = Roact.createElement("UICorner", {}),
				UIStroke = Roact.createElement("UIStroke", {
					Color = Color3.fromHex("ffb625"),
					Thickness = 2,
				}),
				PriceText = Text({
					text = `x8 - {Template.Messages.Robux_Icon}{MonetizationController:GetPrice(props.product8) or props.price8}`,
					color = Color3.fromHex("ffffff"),
					anchorPoint = Vector2.new(0.5, 0.5),
					position = UDim2.fromScale(0.5, 0.5),
					index = 3,
					size = UDim2.fromScale(0.8, 0.6),
					stroke = 1.5,
					strokeColor = Color3.fromHex("a3690c"),
				}),
			}),
			List = Roact.createElement("UIListLayout", {
				Padding = UDim.new(0.03, 0),
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
		}),
	})
end
