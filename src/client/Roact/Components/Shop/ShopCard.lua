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
local RoactSpring = require(ReplicatedStorage.Packages.RoactSpring)

-- Components
local Components = StarterPlayerScripts.Client.Roact.Components
local AspectRatio = require(Components.AspectRatio)
local Text = require(Components.Text)
local Stroke = require(Components.Stroke)
local Corner = require(Components.Corner)
local ShopButton = require(Components.Shop.ShopButton)
local Image = require(Components.Image)

-- Controllers
local DataCacheController = Knit.GetController("DataCacheController")
local MonetizationController = Knit.GetController("MonetizationController")

-- UI
local Template = DataCacheController:GetFile("Template")
local UI = DataCacheController:GetFile("Images")

-- ShopIcon
return function(frameParams: table, itemParams: table, nameBypass: string?)
	setmetatable(frameParams, {
		__index = {
			position = UDim2.fromScale(0.5, 0.5) :: UDim2,
			size = UDim2.fromScale(1, 1) :: UDim2,
			hooks = nil,
			pet = false,
			order = 0,
		},
	})

	setmetatable(itemParams, {
		__index = {
			Name = "" :: string,
			Icon = "" :: string,
			Price = 0 :: number,
			Text = "" :: string,
		},
	})

	local styles, api = RoactSpring.useSpring(frameParams.hooks, function()
		return {
			from = { Rotation = 0,sizeAlpha = 1, },
			to = { Rotation = 36000 },
			loop = true,
			reset = false,
			config = { mass = 1, tension = 1000, friction = 50, duration = 800 },
		}
	end)

	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = frameParams.position,
		Size = frameParams.size,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		ZIndex = 2,
		LayoutOrder = frameParams.order,
	}, {
		Corner = Corner({ radius = 0.1 }),
		Stroke = Stroke({ thick = 3 }),

		Star = Image({
			visible = frameParams.pet,
			image = UI.Star,
			position = UDim2.fromScale(0.5, 0.5),
			size = UDim2.fromScale(1, 1),
			backgroundTransparency = 1,
			index = 3,
			rotation = styles.Rotation,
			children = {
				Gradient = Roact.createElement("UIGradient", {
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
						ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 255, 0)),
						ColorSequenceKeypoint.new(0.4, Color3.fromRGB(0, 255, 0)),
						ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0, 255, 255)),
						ColorSequenceKeypoint.new(0.8, Color3.fromRGB(0, 0, 255)),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 255)),
					}),
				}),
			},
		}),

		Name = Text({
			text = nameBypass and nameBypass or itemParams.Name,
			color = Color3.fromRGB(255, 234, 1),
			backgroundTransparency = 1,
			position = UDim2.fromScale(0.5, 0.1),
			size = UDim2.fromScale(0.668, 0.129),
			index = 3,
			stroke = 1.5,
		}),
		Multiplier = Text({
			text = itemParams.Text,
			color = Color3.fromRGB(85, 255, 127),
			backgroundTransparency = 1,
			position = UDim2.fromScale(0.5, 0.8),
			size = UDim2.fromScale(0.668, 0.129),
			index = 3,
			stroke = 1.5,
		}),

		Icon = Image({
			image = UI[itemParams.Icon],
			backgroundTransparency = 1,
			position = UDim2.fromScale(0.5, 0.456),
			size = UDim2.fromScale(0.7, 0.7),
			index = 3,
			children = { Ratio = AspectRatio({ ratio = 1 }) },
		}),

		ShopButton = ShopButton({
			text = `{Template.Messages.Robux_Icon} {MonetizationController:GetPrice(itemParams.Name)}`,
			position = UDim2.fromScale(0.5, 1),
			size = UDim2.fromScale(0.8, 0.2),
			color = Color3.fromRGB(111, 255, 0),
			buy = itemParams.Name,
			hooks = frameParams.hooks,
		}),
	})
end
