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

-- Controllers
local DataCacheController = Knit.GetController("DataCacheController")

-- UI
local Template = DataCacheController:GetFile("Template")
local Colors = DataCacheController:GetFile("Colors")

-- Pets
return function(hooks)
	return Roact.createElement("Frame", {
		Position = UDim2.fromScale(2.84, 0),
		Size = UDim2.fromScale(1.2, 0.95),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		ClipsDescendants = true,
		LayoutOrder = 3,
	}, {
		Gradient = Gradient({
			startColor = Colors.Gradients.Yellow.startColor,
			endColor = Colors.Gradients.Yellow.endColor,
			rotation = 270,
		}),
		Corner = Corner({ radius = 0.04 }),
		Stroke = Stroke({ thick = 3 }),

		Name = Text({
			text = "Limited OP Pets",
			position = UDim2.fromScale(0.2, 0.077),
			size = UDim2.fromScale(0.411, 0.1),
			backgroundTransparency = 1,
			color = Color3.fromRGB(255, 255, 255),
			index = 3,
			stroke = 2,
		}),
		Duration = Text({
			text = "Renews In",
			position = UDim2.fromScale(0.85, 0.077),
			size = UDim2.fromScale(0.218, 0.094),
			backgroundTransparency = 1,
			color = Color3.fromRGB(255, 255, 255),
			index = 3,
			stroke = 2,
			align = Enum.TextXAlignment.Right,
		}),
		Duration_Time_Left = Text({
			text = Template.Shop.OP_Pets.Renews_In,
			position = UDim2.fromScale(0.85, 0.177),
			size = UDim2.fromScale(0.218, 0.094),
			backgroundTransparency = 1,
			color = Color3.fromRGB(85, 255, 0),
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
				horizontalAlignment = Enum.HorizontalAlignment.Left,
				verticalAlignment = Enum.VerticalAlignment.Center,
			}),

			Pet4 = ShopCard(
				{ size = UDim2.fromScale(0.225, 0.833), hooks = hooks, pet = true, order = 4 },
				Template.Shop.OP_Pets.Pet_4
			),
			Pet1 = ShopCard(
				{ size = UDim2.fromScale(0.225, 0.833), hooks = hooks, pet = true, order = 3 },
				Template.Shop.OP_Pets.Pet_1
			),
			Pet2 = ShopCard(
				{ size = UDim2.fromScale(0.225, 0.833), hooks = hooks, pet = true, order = 2 },
				Template.Shop.OP_Pets.Pet_2
			),
			Pet3 = ShopCard(
				{ size = UDim2.fromScale(0.225, 0.833), hooks = hooks, pet = true, order = 1 },
				Template.Shop.OP_Pets.Pet_3
			),
		}),
	})
end
