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
		},
	})

	local styles, api = RoactSpring.useSpring(hooks, function()
		return { sizeAlpha = 1 }
	end)

	return Roact.createElement("Frame", {
		LayoutOrder = props.order,
		Position = UDim2.fromScale(0.02, 0.1),
		ClipsDescendants = true,
		BackgroundColor3 = Color3.fromHex("ffffff"),
		Size = styles.sizeAlpha:map(function(alpha)
			return UDim2.fromScale(0.82 * alpha, 0.82 * alpha)
		end),
		ZIndex = 2,
	}, {
		Effect = Roact.createElement("ImageLabel", {
			ImageColor3 = Color3.fromHex("ffcf3e"),
			Image = "rbxassetid://106335669168445",
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.4),
			AnchorPoint = Vector2.new(0.5, 0.5),
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromScale(1.2, 1.2),
			ZIndex = 2,
		}, { Ratio = Roact.createElement("UIAspectRatioConstraint", {}) }),

		Sparkle = Roact.createElement("ImageLabel", {
			Image = UI.Sparkle,
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.4),
			AnchorPoint = Vector2.new(0.5, 0.5),
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromScale(1, 1),
			ZIndex = 2,
		}, { Ratio = Roact.createElement("UIAspectRatioConstraint", {}) }),

		NameText = Text({
			text = props.name,
			position = UDim2.fromScale(0.5, 0.6),
			color = Color3.fromHex("ffffff"),
			index = 3,
			size = UDim2.fromScale(0.9, 0.13),
			stroke = 2,
			strokeColor = Color3.fromRGB(0, 0, 0),
		}),

		BonusText = Text({
			color = Color3.fromHex("ffee00"),
			text = "+EXCLUSIVE SHOOTING ANIMATION",
			position = UDim2.fromScale(0.5, 0.73),
			size = UDim2.fromScale(0.9, 0.13),
			index = 20,
			stroke = 2,
			strokeColor = Color3.fromRGB(0, 0, 0),
		}),
		Value = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(1, 0),
			BackgroundColor3 = Color3.fromHex("ffffff"),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.95, 0.015),
			BorderColor3 = Color3.fromHex("000000"),
			ZIndex = 10,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(0.9, 0.175),
		}, {
			ValueText = Text({
				size = UDim2.fromScale(0.5, 0.65),
				position = UDim2.fromScale(0.761, 0.383),
				text = "x" .. (props.multiplier or 1),
				color = Color3.fromHex("ffffff"),
				index = 3,
				align = Enum.TextXAlignment.Right,
				stroke = 2,
				strokeColor = Color3.fromHex("313131"),
			}),

			Icon = Roact.createElement("ImageLabel", {
				LayoutOrder = 1,
				ScaleType = 3,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Image = UI.Wins,
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
				Padding = UDim.new(0.02, 0),
				ItemLineAlignment = 2,
				FillDirection = 0,
			}),
		}),

		UIStroke = Roact.createElement("UIStroke", { Color = Color3.fromHex("ffffff"), Thickness = 3 }, {
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
		UICorner = Roact.createElement("UICorner", {}),
		Ratio = Roact.createElement("UIAspectRatioConstraint", { AspectRatio = 0.9 }),

		Icon = Roact.createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			ScaleType = Enum.ScaleType.Fit,
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.4),
			ZIndex = 2,
			Image = props.icon,
			Size = UDim2.fromScale(0.9, 0.9),
		}, { Ratio = Roact.createElement("UIAspectRatioConstraint", {}) }),

		Buy = Roact.createElement("ImageButton", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.9),
			Size = UDim2.fromScale(0.8, 0.15),
			ZIndex = 8,
			ClipsDescendants = true,
			BackgroundColor3 = Color3.fromHex("ffd500"),
			[Roact.Event.MouseButton1Click] = function()
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
			UICorner = Roact.createElement("UICorner", {}),
			UIStroke = Roact.createElement("UIStroke", { Color = Color3.fromHex("fbff00"), Thickness = 2 }),
			PriceText = Text({
				text = props.price,
				position = UDim2.fromScale(0.5, 0.5),
				color = Color3.fromHex("903c00"),
				index = 8,
				size = UDim2.fromScale(0.85, 0.7),
			}),
		}),
	})
end

return RoactHooks.new(Roact)(MainCardComp)
