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

-- Components
local Components = StarterPlayerScripts.Client.Roact.Components
local Gradient = require(Components.Gradient)
local Corner = require(Components.Corner)
local Stroke = require(Components.Stroke)
local Text = require(Components.Text)
local List = require(Components.List)
local ShopCard = require(Components.Shop.ShopCard)

-- UI
local DataCacheController = Knit.GetController("DataCacheController")
local Template = DataCacheController:GetFile("Template")
local Colors = DataCacheController:GetFile("Colors")

-- Boosts
return function(hooks)
	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(1.2, 0.95),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		ClipsDescendants = true,
		LayoutOrder = 5,
	}, {
		Gradient = Gradient({
			startColor = Colors.Gradients.Green.startColor,
			endColor = Colors.Gradients.Green.endColor,
			rotation = 90,
		}),
		Corner = Corner({ radius = 0.04 }),
		Stroke = Stroke({ thick = 3 }),

		Name = Text({
			text = "Boosts",
			position = UDim2.fromScale(0.13, 0.077),
			size = UDim2.fromScale(0.411, 0.1),
			backgroundTransparency = 1,
			color = Color3.fromRGB(255, 255, 255),
			index = 3,
			stroke = 2,
		}),
		Description = Text({
			text = Template.Shop.Boosts.Description,
			position = UDim2.fromScale(0.79, 0.1),
			size = UDim2.fromScale(0.318, 0.15),
			backgroundTransparency = 1,
			color = Color3.fromRGB(255, 255, 255),
			index = 3,
			stroke = 2,
			align = Enum.TextXAlignment.Right,
		}),

		Content = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.6),
			Size = UDim2.fromScale(0.934, 0.731),
			BackgroundTransparency = 1,
		}, {
			List = List({
				padding = UDim.new(0.03, 0),
				fillDirection = Enum.FillDirection.Horizontal,
				horizontalAlignment = Enum.HorizontalAlignment.Center,
				verticalAlignment = Enum.VerticalAlignment.Center,
			}),

			--ShopCard({ size = UDim2.fromScale(0.225, 0.833), hooks = hooks }, Template.Shop.Boosts.Money_1),
			ShopCard({ size = UDim2.fromScale(0.225, 0.833), hooks = hooks }, Template.Shop.Boosts.Money_2),
			ShopCard({ size = UDim2.fromScale(0.225, 0.833), hooks = hooks }, Template.Shop.Boosts.Wins),
			ShopCard({ size = UDim2.fromScale(0.225, 0.833), hooks = hooks }, Template.Shop.Boosts.All),
		}),
	})
end
