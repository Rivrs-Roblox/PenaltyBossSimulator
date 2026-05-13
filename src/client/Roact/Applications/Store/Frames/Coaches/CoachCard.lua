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
			multiplier = 2,
			price = "you forgot",
		},
	})

	local styles, api = RoactSpring.useSpring(hooks, function()
		return { sizeAlpha = 1 }
	end)

	return Roact.createElement("Frame", {
		LayoutOrder = props.order,
		Position = UDim2.fromScale(0.022, 0.104),
		ClipsDescendants = true,
		BackgroundColor3 = Color3.fromHex("ffffff"),
		Size = styles.sizeAlpha:map(function(alpha)
			return UDim2.fromScale(0.46 * alpha, 0.89 * alpha)
		end),
		ZIndex = 2,
	}, {
		Effect = Roact.createElement("ImageLabel", {
			ImageColor3 = Color3.fromHex("ffd737"),
			Image = "rbxassetid://106335669168445",
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.283, 0.547),
			AnchorPoint = Vector2.new(0.5, 0.5),
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromScale(0.928, 1.598),
			ZIndex = 2,
		}, { Ratio = Roact.createElement("UIAspectRatioConstraint", {}) }),

		Sparkle = Roact.createElement("ImageLabel", {
			Image = UI.Sparkle,
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.283, 0.547),
			AnchorPoint = Vector2.new(0.5, 0.5),
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromScale(1, 1),
			ZIndex = 2,
		}, { Ratio = Roact.createElement("UIAspectRatioConstraint", {}) }),

		NameText = Text({
			text = props.name,
			anchorPoint = Vector2.new(1, 0),
			position = UDim2.fromScale(0.97, 0.028),
			color = Color3.fromHex("ffffff"),
			index = 4,
			size = UDim2.fromScale(0.554, 0.37),
			stroke = 2,
			strokeColor = Color3.fromRGB(0, 0, 0),
			align = Enum.TextXAlignment.Right,
		}),

		Value = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(1, 0),
			BackgroundColor3 = Color3.fromHex("ffffff"),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.95, 0.45),
			BorderColor3 = Color3.fromHex("000000"),
			ZIndex = 10,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(0.3, 0.25),
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
				Padding = UDim.new(0.02, 0),
				ItemLineAlignment = 2,
				FillDirection = 0,
			}),
		}),

		UIStroke = Roact.createElement("UIStroke", { Color = Color3.fromHex("ffffff"), Thickness = 3 }, {
			UIGradient = Roact.createElement("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromHex("f698ff")),
					ColorSequenceKeypoint.new(1, Color3.fromHex("992cbd")),
				}),
				Rotation = -90,
			}),
		}),
		UIGradient = Roact.createElement("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromHex("835aff")),
				ColorSequenceKeypoint.new(1, Color3.fromHex("9c00ea")),
			}),
			Rotation = 90,
		}),
		UICorner = Roact.createElement("UICorner", {}),
		Ratio = Roact.createElement("UIAspectRatioConstraint", { AspectRatio = 1.75 }),

		Icon = Roact.createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			ScaleType = Enum.ScaleType.Fit,
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.259, 0.654),
			ZIndex = 2,
			Image = props.icon,
			Size = UDim2.fromScale(0.872, 1.311),
		}, { Ratio = Roact.createElement("UIAspectRatioConstraint", {}) }),

		Buy = Roact.createElement("ImageButton", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.716, 0.844),
			Size = UDim2.fromScale(0.509, 0.216),
			ZIndex = 3,
			ClipsDescendants = true,
			BackgroundColor3 = Color3.fromHex("f89bff"),
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
			UICorner = Roact.createElement("UICorner", {}),
			UIStroke = Roact.createElement("UIStroke", { Color = Color3.fromHex("e96eff"), Thickness = 2 }),
			PriceText = Text({
				text = props.price,
				color = Color3.fromHex("5e257a"),
				index = 3,
				size = UDim2.fromScale(0.85, 0.7),
				position = UDim2.fromScale(0.5, 0.5),
			}),
		}),
	})
end

return RoactHooks.new(Roact)(SubCardComp)
